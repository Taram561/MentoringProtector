import 'dart:ffi';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import '../ffi/core_bindings.dart';
import '../services/helper_bridge.dart';
import '../ffi/app_paths.dart';
import '../models/smart_cache_stats.dart';

bool _backgroundCoreInit(String dllPath) {
  try {
    final dl = DynamicLibrary.open(dllPath);
    final fn = dl.lookupFunction<Void Function(), void Function()>('core_initialize');
    fn();
    return true;
  } catch (_) {
    return false;
  }
}

int _countYaraRulesFromDisk(String yaraRulesDir) {
  try {
    final root = Directory(yaraRulesDir);
    if (!root.existsSync()) return 0;
    int total = 0;
    final re = RegExp(r'^\s*rule\s+', multiLine: true);
    final stack = <Directory>[root];
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      try {
        for (final entity in cur.listSync(followLinks: false)) {
          if (entity is Directory) {
            stack.add(entity);
          } else if (entity is File && (entity.path.endsWith('.yar') || entity.path.endsWith('.yara'))) {
            try {
              total += re.allMatches(entity.readAsStringSync()).length;
            } catch (_) {  }
          }
        }
      } catch (_) {  }
    }
    return total;
  } catch (_) { return 0; }
}

class ModuleStatusProvider extends ChangeNotifier {
  bool _coreInitDone = false;
  bool _realtimeActive = false;
  bool _processActive = false;
  bool _webActive = false;
  bool _memoryScanActive = false;
  bool _etwActive = false;
  bool _yaraAvailable = false;
  bool _archiveScannerSupported = false;
  int _yaraRulesCount = 0;
  int _quarantineCount = 0;
  SmartCacheStats _smartCacheStats = SmartCacheStats.empty();

  bool get coreInitDone => _coreInitDone;
  bool get realtimeActive => _realtimeActive;
  bool get processActive => _processActive;
  bool get webActive => _webActive;
  bool get memoryScanActive => _memoryScanActive;
  bool get etwActive => _etwActive;
  bool get yaraAvailable => _yaraAvailable;
  bool get archiveScannerSupported => _archiveScannerSupported;
  int get yaraRulesCount => _yaraRulesCount;
  int get quarantineCount => _quarantineCount;
  SmartCacheStats get smartCacheStats => _smartCacheStats;

  int get activeModulesCount => (_realtimeActive ? 1 : 0) + (_processActive ? 1 : 0) + (_webActive ? 1 : 0) + (_memoryScanActive ? 1 : 0) + (_etwActive ? 1 : 0);

  bool get allProtectionActive =>
      _realtimeActive && _processActive && _webActive && _memoryScanActive;

  ModuleStatusProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      compute(_backgroundCoreInit, AppPaths.dllPath)
          .then((success) {
        debugPrint('[MP] core init background: ${success ? "OK" : "FAIL"}');
        _coreInitDone = success;
        refreshModuleStates();
        refreshQuarantineCount();
        _refreshYaraRulesCountAsync();
      }).catchError((Object e) {
        debugPrint('[MP] core init background error: $e');
        refreshModuleStates();
      });
    });
  }

  void refreshModuleStates() {
    _refreshModuleStatesImpl();
  }

  void _refreshModuleStatesImpl() {
    if (!CoreBindings.isInitialized) return;
    if (!_coreInitDone) {
      notifyListeners();
      return;
    }
    final b = CoreBindings.instance;
    bool realtime = false, process = false, web = false, memory = false;

    try {
      if (b.isRealtimeMonitoring != null) {
        final map = jsonDecode(b.callReturningString(b.isRealtimeMonitoring!)) as Map<String, dynamic>;
        realtime = map['active'] == true || map['running'] == true;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }
    try {
      if (b.isMonitoringActive != null) {
        final map = jsonDecode(b.callReturningString(b.isMonitoringActive!)) as Map<String, dynamic>;
        process = map['active'] == true || map['running'] == true;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }
    try {
      if (b.webProtectionIsRunning != null) {
        web = b.webProtectionIsRunning!() == 1;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }
    try {
      if (b.getMemoryScanProgress != null) {
        final map = jsonDecode(b.callReturningString(b.getMemoryScanProgress!)) as Map<String, dynamic>;
        memory = map['is_running'] == true;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }

    bool yaraAvail = false;
    try {
      if (b.getYaraStatus != null) {
        final map = jsonDecode(b.callReturningString(b.getYaraStatus!)) as Map<String, dynamic>;
        yaraAvail = map['available'] == true;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }

    bool etw = false;
    try {
      if (b.getEtwStatus != null) {
        final map = jsonDecode(b.callReturningString(b.getEtwStatus!)) as Map<String, dynamic>;
        etw = map['active'] == true || map['running'] == true;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }

    bool archiveSupported = false;
    try {
      if (b.archiveScanSupported != null) {
        final map = jsonDecode(b.callReturningString(b.archiveScanSupported!)) as Map<String, dynamic>;
        archiveSupported = ((map['supported'] as num?)?.toInt() ?? 0) > 0;
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }

    _realtimeActive = realtime;
    _processActive = process;
    _webActive = web;
    _memoryScanActive = memory;
    _etwActive = etw;
    _yaraAvailable = yaraAvail;
    _archiveScannerSupported = archiveSupported;
    notifyListeners();
    if (_yaraRulesCount == 0) _refreshYaraRulesCountAsync();
  }

  void _refreshYaraRulesCountAsync() {
    final yaraDir = p.join(AppPaths.dataDir, 'yara_rules');
    compute(_countYaraRulesFromDisk, yaraDir)
        .then((count) {
      debugPrint('[MP] YARA disk count: $count rules in $yaraDir');
      _yaraRulesCount = count;
      notifyListeners();
    }).catchError((Object e) {
      debugPrint('[MP] YARA disk count failed: $e');
    });
  }

  void refreshQuarantineCount() {
    if (!CoreBindings.isInitialized) return;
    final b = CoreBindings.instance;
    try {
      if (b.getQuarantineList != null) {
        final map = jsonDecode(b.callReturningString(b.getQuarantineList!)) as Map<String, dynamic>;
        _quarantineCount = (map['count'] as num?)?.toInt() ?? 0;
        notifyListeners();
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }
  }

  void refreshSmartCacheStats() {
    if (!CoreBindings.isInitialized) return;
    final b = CoreBindings.instance;
    try {
      if (b.smartScanGetStats != null) {
        final map = jsonDecode(b.callReturningString(b.smartScanGetStats!)) as Map<String, dynamic>;
        _smartCacheStats = SmartCacheStats.fromJson(map);
        notifyListeners();
      }
    } catch (e) { debugPrint('[MP] FFI error: $e'); }
  }

  int enableAllProtection() {
    if (!CoreBindings.isInitialized) return 0;
    if (!_coreInitDone) return 0;
    final b = CoreBindings.instance;
    int enabled = 0;

    if (b.serviceHosting) {
      final serviceCmds = <String>[];
      if (!_realtimeActive) { serviceCmds.add('realtime_start'); enabled++; }
      if (!_webActive) { serviceCmds.add('web_start'); enabled++; }
      if (serviceCmds.isNotEmpty) {
        HelperBridge.runServiceCmds(serviceCmds).then((r) {
          if (!r.ok && !r.userCancelled) debugPrint('[MP] enableAllProtection: runServiceCmds failed: ${r.message}');
          refreshModuleStates();
        });
      }
      if (!_processActive) {
        try {
          if (b.startProcessMonitoring != null) { b.callReturningString(b.startProcessMonitoring!); enabled++; }
        } catch (e) { debugPrint('[MP] FFI error: $e'); }
      }
      if (!_memoryScanActive) {
        try {
          if (b.startMemoryScan != null) { b.callReturningString(b.startMemoryScan!); enabled++; }
        } catch (e) { debugPrint('[MP] FFI error: $e'); }
      }
      refreshModuleStates();
      return enabled;
    }

    if (!_realtimeActive) {
      try {
        if (b.startRealtimeMonitor != null) { b.callReturningString(b.startRealtimeMonitor!); enabled++; }
      } catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    if (!_processActive) {
      try {
        if (b.startProcessMonitoring != null) { b.callReturningString(b.startProcessMonitoring!); enabled++; }
      } catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    if (!_webActive) {
      try {
        if (b.webProtectionStart != null) {
          b.callStartWeb(b.webProtectionStart!, AppPaths.phishingDomainsPath, AppPaths.safeDomainsPath);
          enabled++;
        }
      } catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    if (!_memoryScanActive) {
      try {
        if (b.startMemoryScan != null) { b.callReturningString(b.startMemoryScan!); enabled++; }
      } catch (e) { debugPrint('[MP] FFI error: $e'); }
    }

    refreshModuleStates();
    return enabled;
  }

  void disableAllProtection() {
    if (!CoreBindings.isInitialized) return;
    if (!_coreInitDone) return;
    final b = CoreBindings.instance;

    if (b.serviceHosting) {
      final serviceCmds = <String>[];
      if (_realtimeActive) serviceCmds.add('realtime_stop');
      if (_webActive) serviceCmds.add('web_stop');
      if (serviceCmds.isNotEmpty) {
        HelperBridge.runServiceCmds(serviceCmds).then((r) {
          if (!r.ok && !r.userCancelled) debugPrint('[MP] disableAllProtection: runServiceCmds failed: ${r.message}');
          refreshModuleStates();
        });
      }
      if (_processActive) {
        try { if (b.stopProcessMonitoring != null) b.callReturningString(b.stopProcessMonitoring!); }
        catch (e) { debugPrint('[MP] FFI error: $e'); }
      }
      if (_memoryScanActive) {
        try { if (b.stopMemoryScan != null) b.callReturningString(b.stopMemoryScan!); }
        catch (e) { debugPrint('[MP] FFI error: $e'); }
      }
      refreshModuleStates();
      return;
    }

    if (_realtimeActive) {
      try { if (b.stopRealtimeMonitor != null) b.callReturningString(b.stopRealtimeMonitor!); }
      catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    if (_processActive) {
      try { if (b.stopProcessMonitoring != null) b.callReturningString(b.stopProcessMonitoring!); }
      catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    if (_webActive) {
      try { if (b.webProtectionStop != null) b.webProtectionStop!(); }
      catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    if (_memoryScanActive) {
      try { if (b.stopMemoryScan != null) b.callReturningString(b.stopMemoryScan!); }
      catch (e) { debugPrint('[MP] FFI error: $e'); }
    }

    refreshModuleStates();
  }
}

