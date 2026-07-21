import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'app_paths.dart';

sealed class DllInitResult { const DllInitResult(); }
final class DllInitSuccess extends DllInitResult { const DllInitSuccess(); }
final class DllInitFailure extends DllInitResult { final String reason; const DllInitFailure(this.reason); }

const int _kApiMajor = 1;

typedef _NativeNoArgFn = Pointer<Utf8> Function();
typedef _DartNoArgFn = Pointer<Utf8> Function();
typedef _NativeGetApiVersion = Uint32 Function();
typedef _DartGetApiVersion = int Function();
typedef _NativeStringFn = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _DartStringFn = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _NativeScanFile = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _DartScanFile = Pointer<Utf8> Function(Pointer<Utf8>);
typedef _NativeFreeString = Void Function(Pointer<Utf8>);
typedef _DartFreeString = void Function(Pointer<Utf8>);
typedef _NativeAnalyzeProcess = Pointer<Utf8> Function(Int32);
typedef _DartAnalyzeProcess = Pointer<Utf8> Function(int);
typedef _NativeGetThreatStats = Pointer<Utf8> Function(Int32 periodDays);
typedef _DartGetThreatStats = Pointer<Utf8> Function(int periodDays);
typedef _NativeGetScanHistory = Pointer<Utf8> Function(Int32 periodDays);
typedef _DartGetScanHistory = Pointer<Utf8> Function(int periodDays);
typedef _NativeGetThreatSources = Pointer<Utf8> Function(Int32 periodDays);
typedef _DartGetThreatSources = Pointer<Utf8> Function(int periodDays);
typedef _NativeIntResult = Int32 Function();
typedef _DartIntResult = int Function();
typedef _NativeStartWeb = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _DartStartWeb = int Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _NativeReloadDb = Int32 Function(Pointer<Utf8>);
typedef _DartReloadDb = int Function(Pointer<Utf8>);
typedef _NativeVoidFn = Void Function();
typedef _DartVoidFn = void Function();
typedef _NativeTrayShowBalloon = Void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _DartTrayShowBalloon = void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _NativeIntStringFn = Int32 Function(Pointer<Utf8>);
typedef _DartIntStringFn = int Function(Pointer<Utf8>);
typedef _NativeQuarantineFile = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Int32, Pointer<Utf8>, Pointer<Utf8>);
typedef _DartQuarantineFile = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, int, Pointer<Utf8>, Pointer<Utf8>);

class CoreBindings {
  CoreBindings._internal() {
    _library = DynamicLibrary.open(AppPaths.dllPath);
    _bindAll();
  }

  static CoreBindings? _instance;
  late final DynamicLibrary _library;

  static bool get isInitialized => _instance != null;

  static DllInitResult tryInitialize() {
    try {
      final instance = CoreBindings._internal();
      final version = instance.getApiVersion();
      final coreMajor = (version >> 16) & 0xFFFF;
      if (coreMajor != _kApiMajor) return DllInitFailure('ABI mismatch: core major=$coreMajor, gui expects $_kApiMajor. Rebuild the DLL or update the GUI.');
      _instance = instance;
      return const DllInitSuccess();
    } on ArgumentError catch (e) {
      return DllInitFailure('DLL не найдена: $e');
    } catch (e) {
      return DllInitFailure('Ошибка загрузки DLL: $e');
    }
  }

  static CoreBindings get instance {
    if (_instance == null) throw StateError('CoreBindings не инициализирован.');
    return _instance!;
  }

  late final _DartGetApiVersion getApiVersion;
  _DartIntResult? reloadSignatures;
  late final _DartScanFile scanFile;
  _DartStringFn? getFileHash;
  _DartNoArgFn? getQuarantineList;
  late final _DartNoArgFn getCoreVersion;
  late final _DartFreeString freeString;
  _DartNoArgFn? coreInitialize;
  _DartNoArgFn? getActiveEngines;
  _DartNoArgFn? scanComputerStart;
  _DartNoArgFn? scanComputerGetProgress;
  _DartNoArgFn? scanComputerStop;
  _DartQuarantineFile? quarantineFile;
  _DartStringFn? restoreFile;
  _DartStringFn? deleteFromQuarantine;
  _DartNoArgFn? startProcessMonitoring;
  _DartNoArgFn? stopProcessMonitoring;
  _DartNoArgFn? getProcessAlerts;
  _DartNoArgFn? isMonitoringActive;
  _DartAnalyzeProcess? analyzeProcessByPid;
  _DartAnalyzeProcess? terminateProcessByPid;
  _DartNoArgFn? scanVulnerabilities;
  _DartStringFn? getVulnFixDescriptor;
  _DartNoArgFn? startRealtimeMonitor;
  _DartNoArgFn? stopRealtimeMonitor;
  _DartNoArgFn? isRealtimeMonitoring;
  _DartNoArgFn? getRealtimeEvents;
  _DartNoArgFn? startMemoryScan;
  _DartNoArgFn? stopMemoryScan;
  _DartNoArgFn? getMemoryScanProgress;
  _DartAnalyzeProcess? scanProcessMemory;
  _DartNoArgFn? getEtwStatus;
  _DartNoArgFn? getDllInjectionAlerts;
  _DartNoArgFn? getYaraStatus;
  _DartNoArgFn? yaraReloadRules;
  _DartNoArgFn? smartScanGetStats;
  _DartNoArgFn? smartScanInvalidate;
  _DartNoArgFn? smartScanClear;
  _DartGetThreatStats? getThreatStats;
  _DartGetScanHistory? getScanHistory;
  _DartGetThreatSources? getThreatSources;
  _DartNoArgFn? getExclusions;
  _DartStringFn? addExclusion;
  _DartStringFn? removeExclusion;
  _DartIntStringFn? verifyHelperExe;
  _DartIntResult? serviceIsRunning;
  _DartNoArgFn? sandboxIsSupported;
  _DartStringFn? sandboxRun;
  _DartNoArgFn? sandboxGetStatus;
  _DartNoArgFn? sandboxGetReport;
  _DartNoArgFn? sandboxCancel;
  _DartNoArgFn? nudgeGetPending;
  _DartTrayShowBalloon? trayShowBalloon;
  _DartNoArgFn? trayConsumeClick;
  _DartNoArgFn? archiveScanSupported;
  _DartStartWeb? webProtectionStart;
  _DartVoidFn? webProtectionStop;
  _DartIntResult? webProtectionIsRunning;
  _DartScanFile? webProtectionCheckUrl;
  _DartIntResult? webProtectionThreatsCount;
  _DartReloadDb? webProtectionReloadDb;
  _DartNoArgFn? webProtectionGetAuthToken;
  _DartIntResult? webProtectionRegenerateToken;

  void _bindAll() {
    getApiVersion = _library.lookup<NativeFunction<_NativeGetApiVersion>>('mp_get_api_version').asFunction<_DartGetApiVersion>();
    scanFile = _library.lookup<NativeFunction<_NativeScanFile>>('scan_file').asFunction<_DartScanFile>();
    freeString = _library.lookup<NativeFunction<_NativeFreeString>>('free_string').asFunction<_DartFreeString>();
    getCoreVersion = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_core_version').asFunction<_DartNoArgFn>();
    _tryBind(() { reloadSignatures = _library.lookup<NativeFunction<_NativeIntResult>>('reload_signatures').asFunction<_DartIntResult>(); });
    _tryBind(() { coreInitialize = _library.lookup<NativeFunction<_NativeNoArgFn>>('core_initialize').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getActiveEngines = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_active_engines').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getFileHash = _library.lookup<NativeFunction<_NativeStringFn>>('get_file_hash').asFunction<_DartStringFn>(); });
    _tryBind(() { getQuarantineList = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_quarantine_list').asFunction<_DartNoArgFn>(); });
    _tryBind(() { quarantineFile = _library.lookup<NativeFunction<_NativeQuarantineFile>>('quarantine_file').asFunction<_DartQuarantineFile>(); });
    _tryBind(() { restoreFile = _library.lookup<NativeFunction<_NativeStringFn>>('restore_file').asFunction<_DartStringFn>(); });
    _tryBind(() { deleteFromQuarantine = _library.lookup<NativeFunction<_NativeStringFn>>('delete_from_quarantine').asFunction<_DartStringFn>(); });
    _tryBind(() { startProcessMonitoring = _library.lookup<NativeFunction<_NativeNoArgFn>>('start_process_monitoring').asFunction<_DartNoArgFn>(); });
    _tryBind(() { stopProcessMonitoring = _library.lookup<NativeFunction<_NativeNoArgFn>>('stop_process_monitoring').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getProcessAlerts = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_process_alerts').asFunction<_DartNoArgFn>(); });
    _tryBind(() { isMonitoringActive = _library.lookup<NativeFunction<_NativeNoArgFn>>('is_monitoring').asFunction<_DartNoArgFn>(); });
    _tryBind(() { analyzeProcessByPid = _library.lookup<NativeFunction<_NativeAnalyzeProcess>>('analyze_process').asFunction<_DartAnalyzeProcess>(); });
    _tryBind(() { terminateProcessByPid = _library.lookup<NativeFunction<_NativeAnalyzeProcess>>('terminate_process_by_pid').asFunction<_DartAnalyzeProcess>(); });
    _tryBind(() { scanVulnerabilities = _library.lookup<NativeFunction<_NativeNoArgFn>>('scan_vulnerabilities').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getVulnFixDescriptor = _library.lookup<NativeFunction<_NativeStringFn>>('get_vuln_fix_descriptor').asFunction<_DartStringFn>(); });
    _tryBind(() { scanComputerStart = _library.lookup<NativeFunction<_NativeNoArgFn>>('scan_computer_start').asFunction<_DartNoArgFn>(); });
    _tryBind(() { scanComputerGetProgress = _library.lookup<NativeFunction<_NativeNoArgFn>>('scan_computer_get_progress').asFunction<_DartNoArgFn>(); });
    _tryBind(() { scanComputerStop = _library.lookup<NativeFunction<_NativeNoArgFn>>('scan_computer_stop').asFunction<_DartNoArgFn>(); });
    _tryBind(() { startRealtimeMonitor = _library.lookup<NativeFunction<_NativeNoArgFn>>('start_realtime_monitor').asFunction<_DartNoArgFn>(); });
    _tryBind(() { stopRealtimeMonitor = _library.lookup<NativeFunction<_NativeNoArgFn>>('stop_realtime_monitor').asFunction<_DartNoArgFn>(); });
    _tryBind(() { isRealtimeMonitoring = _library.lookup<NativeFunction<_NativeNoArgFn>>('is_realtime_monitoring').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getRealtimeEvents = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_realtime_events').asFunction<_DartNoArgFn>(); });
    _tryBind(() { startMemoryScan = _library.lookup<NativeFunction<_NativeNoArgFn>>('start_memory_scan').asFunction<_DartNoArgFn>(); });
    _tryBind(() { stopMemoryScan = _library.lookup<NativeFunction<_NativeNoArgFn>>('stop_memory_scan').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getMemoryScanProgress = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_memory_scan_progress').asFunction<_DartNoArgFn>(); });
    _tryBind(() { scanProcessMemory = _library.lookup<NativeFunction<_NativeAnalyzeProcess>>('scan_process_memory').asFunction<_DartAnalyzeProcess>(); });
    _tryBind(() { getEtwStatus = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_etw_status').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getDllInjectionAlerts = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_dll_injection_alerts').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getYaraStatus = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_yara_status').asFunction<_DartNoArgFn>(); });
    _tryBind(() { yaraReloadRules = _library.lookup<NativeFunction<_NativeNoArgFn>>('yara_reload_rules').asFunction<_DartNoArgFn>(); });
    _tryBind(() { smartScanGetStats = _library.lookup<NativeFunction<_NativeNoArgFn>>('smart_scan_get_stats').asFunction<_DartNoArgFn>(); });
    _tryBind(() { smartScanInvalidate = _library.lookup<NativeFunction<_NativeNoArgFn>>('smart_scan_invalidate').asFunction<_DartNoArgFn>(); });
    _tryBind(() { smartScanClear = _library.lookup<NativeFunction<_NativeNoArgFn>>('smart_scan_clear').asFunction<_DartNoArgFn>(); });
    _tryBind(() { getThreatStats = _library.lookup<NativeFunction<_NativeGetThreatStats>>('get_threat_stats').asFunction<_DartGetThreatStats>(); });
    _tryBind(() { getScanHistory = _library.lookup<NativeFunction<_NativeGetScanHistory>>('get_scan_history').asFunction<_DartGetScanHistory>(); });
    _tryBind(() { getThreatSources = _library.lookup<NativeFunction<_NativeGetThreatSources>>('get_threat_sources').asFunction<_DartGetThreatSources>(); });
    _tryBind(() { getExclusions = _library.lookup<NativeFunction<_NativeNoArgFn>>('get_exclusions').asFunction<_DartNoArgFn>(); });
    _tryBind(() { addExclusion = _library.lookup<NativeFunction<_NativeStringFn>>('add_exclusion').asFunction<_DartStringFn>(); });
    _tryBind(() { removeExclusion = _library.lookup<NativeFunction<_NativeStringFn>>('remove_exclusion').asFunction<_DartStringFn>(); });
    _tryBind(() { verifyHelperExe = _library.lookup<NativeFunction<_NativeIntStringFn>>('mp_verify_helper_exe').asFunction<_DartIntStringFn>(); });
    _tryBind(() { serviceIsRunning = _library.lookup<NativeFunction<_NativeIntResult>>('mp_service_is_running').asFunction<_DartIntResult>(); });
    _tryBind(() { sandboxIsSupported = _library.lookup<NativeFunction<_NativeNoArgFn>>('sandbox_is_supported').asFunction<_DartNoArgFn>(); });
    _tryBind(() { sandboxRun = _library.lookup<NativeFunction<_NativeStringFn>>('sandbox_run').asFunction<_DartStringFn>(); });
    _tryBind(() { sandboxGetStatus = _library.lookup<NativeFunction<_NativeNoArgFn>>('sandbox_get_status').asFunction<_DartNoArgFn>(); });
    _tryBind(() { sandboxGetReport = _library.lookup<NativeFunction<_NativeNoArgFn>>('sandbox_get_report').asFunction<_DartNoArgFn>(); });
    _tryBind(() { sandboxCancel = _library.lookup<NativeFunction<_NativeNoArgFn>>('sandbox_cancel').asFunction<_DartNoArgFn>(); });
    _tryBind(() { nudgeGetPending = _library.lookup<NativeFunction<_NativeNoArgFn>>('nudge_get_pending').asFunction<_DartNoArgFn>(); });
    _tryBind(() { trayShowBalloon = _library.lookup<NativeFunction<_NativeTrayShowBalloon>>('tray_show_balloon').asFunction<_DartTrayShowBalloon>(); });
    _tryBind(() { trayConsumeClick = _library.lookup<NativeFunction<_NativeNoArgFn>>('tray_consume_click').asFunction<_DartNoArgFn>(); });
    _tryBind(() { archiveScanSupported = _library.lookup<NativeFunction<_NativeNoArgFn>>('archive_scan_supported').asFunction<_DartNoArgFn>(); });
    _tryBind(() { webProtectionStart = _library.lookup<NativeFunction<_NativeStartWeb>>('web_protection_start').asFunction<_DartStartWeb>(); });
    _tryBind(() { webProtectionStop = _library.lookup<NativeFunction<_NativeVoidFn>>('web_protection_stop').asFunction<_DartVoidFn>(); });
    _tryBind(() { webProtectionIsRunning = _library.lookup<NativeFunction<_NativeIntResult>>('web_protection_is_running').asFunction<_DartIntResult>(); });
    _tryBind(() { webProtectionCheckUrl = _library.lookup<NativeFunction<_NativeScanFile>>('web_protection_check_url').asFunction<_DartScanFile>(); });
    _tryBind(() { webProtectionThreatsCount = _library.lookup<NativeFunction<_NativeIntResult>>('web_protection_threats_count').asFunction<_DartIntResult>(); });
    _tryBind(() { webProtectionReloadDb = _library.lookup<NativeFunction<_NativeReloadDb>>('web_protection_reload_db').asFunction<_DartReloadDb>(); });
    _tryBind(() { webProtectionGetAuthToken = _library.lookup<NativeFunction<_NativeNoArgFn>>('web_protection_get_auth_token').asFunction<_DartNoArgFn>(); });
    _tryBind(() { webProtectionRegenerateToken = _library.lookup<NativeFunction<_NativeIntResult>>('web_protection_regenerate_token').asFunction<_DartIntResult>(); });
  }

  bool get serviceHosting => serviceIsRunning?.call() == 1;

  void _tryBind(void Function() bind) {
    try { bind(); } catch (e) { debugPrint('[MP] bind skip: $e'); }
  }

  static const List<int> _cp1251Ext = [
    0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021,
    0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F,
    0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
    0x0000, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F,
    0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7,
    0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407,
    0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7,
    0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457,
  ];

  static String _decodeWindows1251(Uint8List bytes) {
    final buf = StringBuffer();
    for (final b in bytes) {
      if (b < 0x80) buf.writeCharCode(b);
      else if (b < 0xC0) { final cp = _cp1251Ext[b - 0x80]; buf.writeCharCode(cp != 0 ? cp : 0xFFFD); }
      else if (b < 0xE0) buf.writeCharCode(0x0410 + (b - 0xC0));
      else buf.writeCharCode(0x0430 + (b - 0xE0));
    }
    return buf.toString();
  }

  static String _ptrToString(Pointer<Utf8> ptr) {
    try { return ptr.toDartString(); } on FormatException { final bytes = ptr.cast<Uint8>().asTypedList(ptr.length); return _decodeWindows1251(bytes); }
  }

  String callReturningString(_DartNoArgFn fn) {
    final ptr = fn();
    if (ptr.address == 0) return '';
    try { return _ptrToString(ptr); } finally { freeString(ptr); }
  }

  String callWithOneStringArg(_DartStringFn fn, String arg) {
    return using((arena) {
      final argPtr = arg.toNativeUtf8(allocator: arena);
      final ptr = fn(argPtr);
      if (ptr.address == 0) return '';
      try { return _ptrToString(ptr); } finally { freeString(ptr); }
    });
  }

  void callTrayShowBalloon(_DartTrayShowBalloon fn, String title, String text) {
    using((arena) { fn(title.toNativeUtf8(allocator: arena), text.toNativeUtf8(allocator: arena)); });
  }

  String callWithIntArg(_DartAnalyzeProcess fn, int arg) {
    final ptr = fn(arg);
    if (ptr.address == 0) return '';
    try { return _ptrToString(ptr); } finally { freeString(ptr); }
  }

  String callQuarantineFile(_DartQuarantineFile fn, String filePath, String threatName, String threatType, int dangerLevel) {
    return using((arena) {
      final fp = filePath.toNativeUtf8(allocator: arena);
      final tn = threatName.toNativeUtf8(allocator: arena);
      final tt = threatType.toNativeUtf8(allocator: arena);
      final fh = ''.toNativeUtf8(allocator: arena);
      final dm = 'memory_scan'.toNativeUtf8(allocator: arena);
      final res = fn(fp, tn, tt, dangerLevel, fh, dm);
      if (res.address == 0) return '';
      try { return _ptrToString(res); } finally { freeString(res); }
    });
  }

  int callStartWeb(_DartStartWeb fn, String phishingDb, String safeList) {
    return using((arena) {
      final p1 = phishingDb.toNativeUtf8(allocator: arena);
      final p2 = safeList.toNativeUtf8(allocator: arena);
      return fn(p1, p2);
    });
  }

  int callReloadDb(_DartReloadDb fn, String path) {
    return using((arena) { final p = path.toNativeUtf8(allocator: arena); return fn(p); });
  }

  String? callGetThreatStats(int periodDays) {
    if (getThreatStats == null) return null;
    final ptr = getThreatStats!(periodDays);
    if (ptr.address == 0) return null;
    try { return _ptrToString(ptr); } finally { freeString(ptr); }
  }

  String? callGetScanHistory(int periodDays) {
    if (getScanHistory == null) return null;
    final ptr = getScanHistory!(periodDays);
    if (ptr.address == 0) return null;
    try { return _ptrToString(ptr); } finally { freeString(ptr); }
  }

  String? callGetThreatSources(int periodDays) {
    if (getThreatSources == null) return null;
    final ptr = getThreatSources!(periodDays);
    if (ptr.address == 0) return null;
    try { return _ptrToString(ptr); } finally { freeString(ptr); }
  }
}

