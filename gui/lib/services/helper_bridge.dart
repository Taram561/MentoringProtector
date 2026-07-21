import 'dart:convert';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import '../ffi/app_paths.dart';
import '../ffi/core_bindings.dart';
import 'elevated_launcher.dart';

class HelperResult {
  final bool ok;
  final bool rebootRequired;
  final bool userCancelled;
  final String message;
  const HelperResult({required this.ok, this.rebootRequired = false, this.userCancelled = false, this.message = ''});
}

final _kVulnIdRe = RegExp(r'^[a-z_]{3,32}$');

final _kServiceCmdRe = RegExp(r'^(realtime_start|realtime_stop|web_start|web_stop)$');

class _RawHelperRun {
  final bool cancelled;
  final String? error;
  final String? json;
  const _RawHelperRun._({this.cancelled = false, this.error, this.json});
  factory _RawHelperRun.cancelled() => const _RawHelperRun._(cancelled: true);
  factory _RawHelperRun.error(String msg) => _RawHelperRun._(error: msg);
  factory _RawHelperRun.ok(String json) => _RawHelperRun._(json: json);
}

class HelperBridge {
  static Future<_RawHelperRun> _runElevatedHelper(List<String> args) async {
    final helperPath = AppPaths.helperExePath;
    if (!File(helperPath).existsSync()) {
      return _RawHelperRun.error('mp_helper.exe not found at $helperPath');
    }

    if (!CoreBindings.isInitialized) {
      return _RawHelperRun.error('helper_verify_unavailable');
    }
    final verify = CoreBindings.instance.verifyHelperExe;
    if (verify == null) {
      return _RawHelperRun.error('helper_verify_unavailable');
    }
    final verified = using((arena) {
      final pathPtr = helperPath.toNativeUtf8(allocator: arena);
      return verify(pathPtr);
    });
    if (verified != 1) {
      return _RawHelperRun.error('helper_signature_invalid');
    }

    final outputPath = createElevatedOutputPath();
    final ElevatedRunResult launch;
    try {
      launch = await ElevatedLauncher.run(helperPath, [...args, '--output-file', outputPath]);
    } catch (e) {
      debugPrint('[MP] _runElevatedHelper: ElevatedLauncher.run threw $e');
      return _RawHelperRun.error('elevation_error: $e');
    }

    if (launch.timedOut) {
      return _RawHelperRun.error('helper_timed_out');
    }
    if (!launch.launched) {
      if (launch.errorCode == errorCancelled) {
        return _RawHelperRun.cancelled();
      }
      return _RawHelperRun.error('elevation_failed (code ${launch.errorCode})');
    }

    final outputFile = File(outputPath);
    if (!outputFile.existsSync()) {
      return _RawHelperRun.error('no_output_from_helper');
    }
    String content;
    try {
      content = outputFile.readAsStringSync().trim();
    } finally {
      try { outputFile.deleteSync(); } catch (_) {}
    }
    return _RawHelperRun.ok(content);
  }

  static Future<HelperResult> runServiceCmd(String cmd) async {
    if (!_kServiceCmdRe.hasMatch(cmd)) {
      return const HelperResult(ok: false, message: 'invalid service cmd');
    }

    final run = await _runElevatedHelper(['--service-cmd', cmd]);
    if (run.cancelled) {
      return const HelperResult(ok: false, userCancelled: true, message: 'user_cancelled');
    }
    if (run.error != null) {
      return HelperResult(ok: false, message: run.error!);
    }

    final raw = run.json!;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ok = map['ok'] == true;
      final msg = (map['message'] as String?) ?? (map['error'] as String?) ?? '';
      return HelperResult(ok: ok, message: msg);
    } catch (e) {
      debugPrint('[MP] HelperBridge.runServiceCmd JSON parse: $e');
      return HelperResult(ok: false, message: 'Parse error: $raw');
    }
  }

  static Future<HelperResult> runServiceCmds(List<String> cmds) async {
    if (cmds.isEmpty) {
      return const HelperResult(ok: true);
    }
    if (!cmds.every(_kServiceCmdRe.hasMatch)) {
      return const HelperResult(ok: false, message: 'invalid service cmd');
    }

    final run = await _runElevatedHelper(['--service-cmds', cmds.join(',')]);
    if (run.cancelled) {
      return const HelperResult(ok: false, userCancelled: true, message: 'user_cancelled');
    }
    if (run.error != null) {
      return HelperResult(ok: false, message: run.error!);
    }

    final raw = run.json!;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ok = map['ok'] == true;
      return HelperResult(ok: ok, message: ok ? '' : 'one or more commands failed');
    } catch (e) {
      debugPrint('[MP] HelperBridge.runServiceCmds JSON parse: $e');
      return HelperResult(ok: false, message: 'Parse error: $raw');
    }
  }

  static Future<HelperResult> runFix(String vulnId) async {
    if (!_kVulnIdRe.hasMatch(vulnId)) {
      return const HelperResult(ok: false, message: 'invalid vuln_id');
    }

    final run = await _runElevatedHelper(['--fix', vulnId]);
    if (run.cancelled) {
      return const HelperResult(ok: false, userCancelled: true, message: 'user_cancelled');
    }
    if (run.error != null) {
      return HelperResult(ok: false, message: run.error!);
    }

    final raw = run.json!;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ok = map['ok'] == true;
      final reboot = map['reboot_required'] == true;
      final msg = (map['message'] as String?) ?? '';
      final errorCode = (map['error_code'] as num?)?.toInt() ?? 0;

      if (!ok && errorCode == errorCancelled) {
        return const HelperResult(ok: false, userCancelled: true, message: 'user_cancelled');
      }
      return HelperResult(ok: ok, rebootRequired: reboot, message: msg);
    } catch (e) {
      debugPrint('[MP] HelperBridge JSON parse: $e');
      return HelperResult(ok: false, message: 'Parse error: $raw');
    }
  }
}

