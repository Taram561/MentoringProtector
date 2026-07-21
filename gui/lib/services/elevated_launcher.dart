import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';

final class _ShellExecuteInfoW extends Struct {
  @Uint32()
  external int cbSize;

  @Uint32()
  external int fMask;

  external Pointer<Void> hwnd;

  external Pointer<Utf16> lpVerb;
  external Pointer<Utf16> lpFile;
  external Pointer<Utf16> lpParameters;
  external Pointer<Utf16> lpDirectory;

  @Int32()
  external int nShow;

  external Pointer<Void> hInstApp;
  external Pointer<Void> lpIDList;
  external Pointer<Utf16> lpClass;
  external Pointer<Void> hkeyClass;

  @Uint32()
  external int dwHotKey;

  external Pointer<Void> hIcon;
  external Pointer<Void> hProcess;
}

typedef _ShellExecuteExWNative = Int32 Function(Pointer<_ShellExecuteInfoW>);
typedef _ShellExecuteExWDart = int Function(Pointer<_ShellExecuteInfoW>);

typedef _WaitForSingleObjectNative = Uint32 Function(Pointer<Void>, Uint32);
typedef _WaitForSingleObjectDart = int Function(Pointer<Void>, int);

typedef _CloseHandleNative = Int32 Function(Pointer<Void>);
typedef _CloseHandleDart = int Function(Pointer<Void>);

typedef _GetLastErrorNative = Uint32 Function();
typedef _GetLastErrorDart = int Function();

typedef _TerminateProcessNative = Int32 Function(Pointer<Void>, Uint32);
typedef _TerminateProcessDart = int Function(Pointer<Void>, int);

typedef _CoInitializeExNative = Int32 Function(Pointer<Void>, Uint32);
typedef _CoInitializeExDart = int Function(Pointer<Void>, int);
typedef _CoUninitializeNative = Void Function();
typedef _CoUninitializeDart = void Function();

const int _seeMaskNoCloseProcess = 0x00000040;
const int _swHide = 0;
const int _waitTimeoutMs = 15000;
const int _pollIntervalMs = 100;
const int _launchTimeoutMs = 120000;
const int _coinitApartmentThreaded = 0x2;

const int errorCancelled = 1223;

class ElevatedRunResult {
  final bool launched;
  final int errorCode;
  final bool timedOut;
  const ElevatedRunResult({required this.launched, this.errorCode = 0, this.timedOut = false});
}

String _quoteArg(String arg) => '"${arg.replaceAll('"', '\\"')}"';

class _LaunchOutcome {
  final bool ok;
  final int errorCode;
  final int hProcessAddress;
  const _LaunchOutcome.ok(this.hProcessAddress) : ok = true, errorCode = 0;
  const _LaunchOutcome.fail(this.errorCode) : ok = false, hProcessAddress = 0;
}

_LaunchOutcome _launchElevatedBlocking(List<String> payload) {
  final exePath = payload[0];
  final args = payload.sublist(1);

  final ole32 = DynamicLibrary.open('ole32.dll');
  final coInitializeEx = ole32.lookupFunction<_CoInitializeExNative, _CoInitializeExDart>('CoInitializeEx');
  final coUninitialize = ole32.lookupFunction<_CoUninitializeNative, _CoUninitializeDart>('CoUninitialize');

  final shell32 = DynamicLibrary.open('shell32.dll');
  final shellExecuteEx = shell32.lookupFunction<_ShellExecuteExWNative, _ShellExecuteExWDart>('ShellExecuteExW');
  final kernel32 = DynamicLibrary.open('kernel32.dll');
  final getLastError = kernel32.lookupFunction<_GetLastErrorNative, _GetLastErrorDart>('GetLastError');

  final coResult = coInitializeEx(nullptr, _coinitApartmentThreaded);
  final comInitializedByUs = coResult == 0;

  final info = calloc<_ShellExecuteInfoW>();
  final verbPtr = 'runas'.toNativeUtf16();
  final filePtr = exePath.toNativeUtf16();
  final paramsPtr = args.map(_quoteArg).join(' ').toNativeUtf16();

  try {
    info.ref.cbSize = sizeOf<_ShellExecuteInfoW>();
    info.ref.fMask = _seeMaskNoCloseProcess;
    info.ref.lpVerb = verbPtr;
    info.ref.lpFile = filePtr;
    info.ref.lpParameters = paramsPtr;
    info.ref.nShow = _swHide;

    final ok = shellExecuteEx(info) != 0;
    if (!ok) {
      return _LaunchOutcome.fail(getLastError());
    }
    return _LaunchOutcome.ok(info.ref.hProcess.address);
  } finally {
    calloc.free(info);
    calloc.free(verbPtr);
    calloc.free(filePtr);
    calloc.free(paramsPtr);
    if (comInitializedByUs) coUninitialize();
  }
}

class ElevatedLauncher {
  static Future<void> _queue = Future.value();

  static Future<ElevatedRunResult> run(String exePath, List<String> args) async {
    final previous = _queue;
    final completer = Completer<void>();
    _queue = completer.future;
    await previous;
    try {
      return await _runExclusive(exePath, args);
    } finally {
      completer.complete();
    }
  }

  static Future<ElevatedRunResult> _runExclusive(String exePath, List<String> args) async {
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    final waitForSingleObject = kernel32.lookupFunction<_WaitForSingleObjectNative, _WaitForSingleObjectDart>('WaitForSingleObject');
    final closeHandle = kernel32.lookupFunction<_CloseHandleNative, _CloseHandleDart>('CloseHandle');
    final terminateProcess = kernel32.lookupFunction<_TerminateProcessNative, _TerminateProcessDart>('TerminateProcess');

    _LaunchOutcome outcome;
    try {
      outcome = await Isolate.run(() => _launchElevatedBlocking([exePath, ...args])).timeout(const Duration(milliseconds: _launchTimeoutMs));
    } on TimeoutException {
      return const ElevatedRunResult(launched: false, timedOut: true);
    }
    if (!outcome.ok) {
      return ElevatedRunResult(launched: false, errorCode: outcome.errorCode);
    }
    if (outcome.hProcessAddress == 0) {
      return const ElevatedRunResult(launched: true);
    }

    final hProcess = Pointer<Void>.fromAddress(outcome.hProcessAddress);
    const waitObjectZero = 0;
    final deadline = DateTime.now().add(const Duration(milliseconds: _waitTimeoutMs));
    try {
      while (DateTime.now().isBefore(deadline)) {
        if (waitForSingleObject(hProcess, 0) == waitObjectZero) {
          return const ElevatedRunResult(launched: true);
        }
        await Future.delayed(const Duration(milliseconds: _pollIntervalMs));
      }
      terminateProcess(hProcess, 1);
      return const ElevatedRunResult(launched: true, timedOut: true);
    } finally {
      closeHandle(hProcess);
    }
  }
}

String createElevatedOutputPath() {
  final dir = Directory.systemTemp;
  final name = 'mp_helper_result_${DateTime.now().microsecondsSinceEpoch}.json';
  return '${dir.path}${Platform.pathSeparator}$name';
}

