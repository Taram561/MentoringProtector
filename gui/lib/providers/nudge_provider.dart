
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../ffi/core_bindings.dart';
import '../ffi/core_service.dart';
import '../models/nudge.dart';
import '../models/user_profile.dart';
import 'user_profile_provider.dart';


enum UsbScanStatus { scanning, complete, error }

class UsbScanState {
  final UsbScanStatus status;
  final int scanned;
  final int total;
  final int threats;
  final List<String> threatNames;
  const UsbScanState({required this.status, this.scanned = 0, this.total = 0, this.threats = 0, this.threatNames = const []});
  bool get isComplete => status == UsbScanStatus.complete;
  bool get isClean => isComplete && threats == 0;
}

class NudgeProvider extends ChangeNotifier {
  final UserProfileProvider _profileProvider;
  final CoreService _coreService = CoreService();

  final List<Nudge> _pending = [];
  List<Nudge> get pending => List.unmodifiable(_pending);

  final Map<String, UsbScanState> _usbScans = {};
  Map<String, UsbScanState> get usbScans => Map.unmodifiable(_usbScans);

  Nudge? _latestForBalloon;
  Nudge? consumeBalloonNudge() {
    final n = _latestForBalloon;
    _latestForBalloon = null;
    return n;
  }

  bool _trayClickPending = false;
  bool consumeTrayClick() {
    final v = _trayClickPending;
    _trayClickPending = false;
    return v;
  }

  NudgeProvider({required UserProfileProvider profileProvider}) : _profileProvider = profileProvider;

  void poll() {
    if (!CoreBindings.isInitialized) return;
    _pollNewNudges();
    _pollTrayClick();
  }

  void _pollNewNudges() {
    final fn = CoreBindings.instance.nudgeGetPending;
    if (fn == null) return;
    try {
      final json = CoreBindings.instance.callReturningString(fn);
      if (json.isEmpty || json == '[]') return;
      final list = jsonDecode(json) as List<dynamic>;
      if (list.isEmpty) return;

      bool added = false;
      Nudge? nonUsbNudge;
      for (final item in list) {
        final nudge = Nudge.fromJson(item as Map<String, dynamic>);
        _pending.add(nudge);
        _latestForBalloon = nudge;
        added = true;
        if (nudge.category == NudgeCategory.usbDevice) {
          final existing = _usbScans[nudge.detail];
          if (existing?.status != UsbScanStatus.scanning) {
            _startUsbAutoScan(nudge);
          }
        } else {
          nonUsbNudge = nudge;
        }
      }
      if (added) {
        if (nonUsbNudge != null) _fireTrayBalloon(nonUsbNudge);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[NudgeProvider] poll error: $e');
    }
  }

  void _pollTrayClick() {
    final fn = CoreBindings.instance.trayConsumeClick;
    if (fn == null) return;
    try {
      final json = CoreBindings.instance.callReturningString(fn);
      if (json.contains('"clicked":true')) {
        _trayClickPending = true;
      }
    } catch (e) {
      debugPrint('[NudgeProvider] trayConsumeClick error: $e');
    }
  }

  void _fireTrayBalloon(Nudge nudge) {
    final fn = CoreBindings.instance.trayShowBalloon;
    if (fn == null) return;
    try {
      final title = _balloonTitle(nudge.category);
      final text = nudge.detail.isNotEmpty ? nudge.detail : nudge.category.name;
      CoreBindings.instance.callTrayShowBalloon(fn, title, text);
    } catch (e) {
      debugPrint('[NudgeProvider] trayShowBalloon error: $e');
    }
  }

  static String _balloonTitle(NudgeCategory cat) => switch (cat) { NudgeCategory.downloadedExe => 'Security Alert', NudgeCategory.suspiciousScript => 'Security Alert', NudgeCategory.macroDocument => 'Security Notice', NudgeCategory.usbDevice => 'Removable Drive', NudgeCategory.downloadedContainer => 'Security Alert' };

  void onEngaged(Nudge nudge) {
    _removePending(nudge);
    _profileProvider.recordEvent(RiskEventType.nudgeEngaged, detail: nudge.detail);
    notifyListeners();
  }

  void onIgnored(Nudge nudge) {
    _removePending(nudge);
    if (nudge.category.isSecurity) _profileProvider.recordEvent(RiskEventType.securityNudgeIgnored, detail: nudge.detail);
    notifyListeners();
  }

  void _removePending(Nudge nudge) {
    _pending.removeWhere((n) => n.category == nudge.category && n.detail == nudge.detail);
  }


  void retriggerUsbScan(Nudge nudge) {
    _usbScans.remove(nudge.detail);
    _startUsbAutoScan(nudge);
  }

  Future<void> _startUsbAutoScan(Nudge nudge) async {
    final driveDetail = nudge.detail;
    final letter = driveDetail.length >= 7 ? driveDetail[6] : '?';
    final drivePath = '$letter:\\';

    _usbScans[driveDetail] = const UsbScanState(status: UsbScanStatus.scanning);
    notifyListeners();

    try {
      final files = await _collectUsbFiles(drivePath);

      _usbScans[driveDetail] = UsbScanState(status: UsbScanStatus.scanning, total: files.length);
      notifyListeners();

      int scanned = 0, threats = 0;
      final threatNames = <String>[];

      for (final filePath in files) {
        try {
          final result = await _coreService.scanFile(filePath);
          scanned++;
          if (result.isInfected) {
            threats++;
            final name = result.filePath.isNotEmpty ? result.filePath.split(r'\').last : filePath.split(r'\').last;
            threatNames.add(name);
          }
        } catch (_) {
          scanned++;
        }

        if (scanned % 50 == 0) {
          _usbScans[driveDetail] = UsbScanState(status: UsbScanStatus.scanning, scanned: scanned, total: files.length, threats: threats, threatNames: List.unmodifiable(threatNames));
          notifyListeners();
        }
      }

      _usbScans[driveDetail] = UsbScanState(status: UsbScanStatus.complete, scanned: scanned, total: files.length, threats: threats, threatNames: List.unmodifiable(threatNames));
      notifyListeners();

      if (threats == 0) _fireTrayBalloonRaw('Диск $letter: проверен', 'Угроз не найдено ($scanned файлов)');
      else _fireTrayBalloonRaw('Диск $letter: найдено угроз - $threats', threatNames.take(3).join(', '));
    } catch (e, st) {
      debugPrint('[NudgeProvider] USB scan error: $e\n$st');
      _usbScans[driveDetail] = const UsbScanState(status: UsbScanStatus.error);
      notifyListeners();
      _fireTrayBalloonRaw('Диск $letter: ошибка проверки', e.toString().substring(0, e.toString().length.clamp(0, 80)));
    }
  }

  void _fireTrayBalloonRaw(String title, String body) {
    final fn = CoreBindings.instance.trayShowBalloon;
    if (fn == null) return;
    try {
      CoreBindings.instance.callTrayShowBalloon(fn, title, body);
    } catch (e) {
      debugPrint('[NudgeProvider] trayBalloonRaw error: $e');
    }
  }

  static const int _usbMaxFiles = 10000;
  static const int _usbMaxBytes = 50 * 1024 * 1024;
  static const _usbSkipExt = {'.msdb', '.yrc', '.log', '.tmp'};

  Future<List<String>> _collectUsbFiles(String drivePath) async {
    final result = <String>[];
    try {
      final dir = Directory(drivePath);
      await for (final entity in dir.list(recursive: true)) {
        if (result.length >= _usbMaxFiles) break;
        if (entity is! File) continue;
        final path = entity.path;
        final dot = path.lastIndexOf('.');
        final ext = dot >= 0 ? path.substring(dot).toLowerCase() : '';
        if (_usbSkipExt.contains(ext)) continue;
        try {
          if ((await entity.stat()).size > _usbMaxBytes) continue;
        } catch (_) {
          continue;
        }
        result.add(path);
      }
    } catch (_) {}
    return result;
  }
}

