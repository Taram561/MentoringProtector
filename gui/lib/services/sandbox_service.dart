import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../ffi/core_bindings.dart';
import '../ffi/service_interfaces.dart' show ISandboxService, SandboxRunResult;
import '../models/sandbox_report.dart';

class SandboxService implements ISandboxService {
  final CoreBindings? _bindings;

  SandboxService({CoreBindings? bindings}) : _bindings = bindings ?? (CoreBindings.isInitialized ? CoreBindings.instance : null);

  @override
  Future<bool> isSupported() async {
    if (_bindings?.sandboxIsSupported == null) return false;
    try {
      final json = _bindings!.callReturningString(_bindings!.sandboxIsSupported!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map['supported'] == true;
    } catch (e) {
      debugPrint('[MP] SandboxService.isSupported: $e');
      return false;
    }
  }

  @override
  Future<SandboxRunResult> run(String filePath) async {
    if (_bindings?.sandboxRun == null) {
      return const SandboxRunResult(success: false, errorCode: 'no_binding');
    }
    try {
      final json = _bindings!.callWithOneStringArg(_bindings!.sandboxRun!, filePath);
      final map = jsonDecode(json) as Map<String, dynamic>;
      return SandboxRunResult.fromJson(map);
    } catch (e) {
      debugPrint('[MP] SandboxService.run: $e');
      return const SandboxRunResult(success: false, errorCode: 'exception');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatus() async {
    if (_bindings?.sandboxGetStatus == null) return {'state': 'idle', 'elapsed': 0};
    try {
      final json = _bindings!.callReturningString(_bindings!.sandboxGetStatus!);
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[MP] SandboxService.getStatus: $e');
      return {'state': 'idle', 'elapsed': 0};
    }
  }

  @override
  Future<SandboxReport> getReport() async {
    if (_bindings?.sandboxGetReport == null) return SandboxReport.empty();
    try {
      final json = _bindings!.callReturningString(_bindings!.sandboxGetReport!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      return SandboxReport.fromJson(map);
    } catch (e) {
      debugPrint('[MP] SandboxService.getReport: $e');
      return SandboxReport.empty();
    }
  }

  @override
  Future<void> cancel() async {
    if (_bindings?.sandboxCancel == null) return;
    try {
      _bindings!.callReturningString(_bindings!.sandboxCancel!);
    } catch (e) {
      debugPrint('[MP] SandboxService.cancel: $e');
    }
  }
}

