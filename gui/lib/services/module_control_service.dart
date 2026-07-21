import 'package:flutter/foundation.dart';
import '../ffi/core_bindings.dart';
import '../ffi/service_interfaces.dart';

class ModuleControlService implements IModuleControlService {
  final CoreBindings _bindings;

  ModuleControlService({CoreBindings? bindings}) : _bindings = bindings ?? CoreBindings.instance;

  @override
  void startRealtime() {
    try {
      if (_bindings.startRealtimeMonitor != null) {
        _bindings.callReturningString(_bindings.startRealtimeMonitor!);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.startRealtime: $e'); }
  }

  @override
  void stopRealtime() {
    try {
      if (_bindings.stopRealtimeMonitor != null) {
        _bindings.callReturningString(_bindings.stopRealtimeMonitor!);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.stopRealtime: $e'); }
  }

  @override
  void startProcessMonitoring() {
    try {
      if (_bindings.startProcessMonitoring != null) {
        _bindings.callReturningString(_bindings.startProcessMonitoring!);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.startProcess: $e'); }
  }

  @override
  void stopProcessMonitoring() {
    try {
      if (_bindings.stopProcessMonitoring != null) {
        _bindings.callReturningString(_bindings.stopProcessMonitoring!);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.stopProcess: $e'); }
  }

  @override
  void startWebProtection(String phishingPath, String safePath) {
    try {
      if (_bindings.webProtectionStart != null) {
        _bindings.callStartWeb(_bindings.webProtectionStart!, phishingPath, safePath);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.startWeb: $e'); }
  }

  @override
  void stopWebProtection() {
    try {
      if (_bindings.webProtectionStop != null) {
        _bindings.webProtectionStop!();
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.stopWeb: $e'); }
  }

  @override
  void startMemoryScan() {
    try {
      if (_bindings.startMemoryScan != null) {
        _bindings.callReturningString(_bindings.startMemoryScan!);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.startMemory: $e'); }
  }

  @override
  void stopMemoryScan() {
    try {
      if (_bindings.stopMemoryScan != null) {
        _bindings.callReturningString(_bindings.stopMemoryScan!);
      }
    } catch (e) { debugPrint('[MP] ModuleControlService.stopMemory: $e'); }
  }

  @override
  Future<bool> reloadYaraRules() async {
    try {
      if (_bindings.yaraReloadRules == null) return false;
      _bindings.callReturningString(_bindings.yaraReloadRules!);
      return true;
    } catch (e) {
      debugPrint('[MP] ModuleControlService.reloadYara: $e');
      return false;
    }
  }
}

