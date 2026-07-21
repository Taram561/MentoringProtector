import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../ffi/core_bindings.dart';
import '../../ffi/core_service.dart';
import '../../models/archived_report.dart';
import '../../models/scan_result.dart';
import '../../services/reports_archive_service.dart';

sealed class ScanState {
  const ScanState();
}

final class ScanIdle extends ScanState {
  const ScanIdle();
}

final class ScanRunning extends ScanState {
  final String currentFile;
  final int    scanned;
  final int    total;
  final int    threatsFound;

  const ScanRunning({
    required this.currentFile,
    required this.scanned,
    required this.total,
    required this.threatsFound,
  });

  double get progress => total > 0 ? scanned / total : 0.0;
}

final class ScanFinished extends ScanState {
  final int scanned;
  final int threatsFound;
  final Duration elapsed;

  const ScanFinished({
    required this.scanned,
    required this.threatsFound,
    required this.elapsed,
  });
}

final class ScanError extends ScanState {
  final String message;
  const ScanError(this.message);
}


class ScanController extends ChangeNotifier {
  final CoreService _service;

  ScanController({CoreService? service})
      : _service = service ?? CoreService();

  ScanState _state = const ScanIdle();
  ScanState get state => _state;

  final List<ScanResult> _results = [];
  List<ScanResult> get results => _results;

  List<ScanResult> get threats =>
      _results.where((r) => r.isInfected).toList();

  bool _cancelled = false;

  bool _paused = false;
  bool get isPaused => _paused;
  Completer<void>? _pauseCompleter;

  bool _isComputerScan = false;
  bool get isComputerScan => _isComputerScan;
  String _computerScanDrive = '';
  String get computerScanDrive => _computerScanDrive;
  Timer? _pollTimer;
  bool _polling = false;
  final _computerStopwatch = Stopwatch();


  Future<void> scanFile(String path) async {
    await _startScan([path]);
  }

  Future<void> scanDirectory(String path) async {
    final files = await _collectFiles(path);
    await _startScan(files);
  }

  Future<void> scanComputer() async {
    final bindings = CoreBindings.instance;
    if (bindings.scanComputerStart == null) return;

    await _ensureYaraReady();

    _cancelled = false;
    _results.clear();
    _isComputerScan = true;
    _computerScanDrive = '';

    _state = const ScanRunning(
      currentFile: '', scanned: 0, total: 0, threatsFound: 0,
    );
    notifyListeners();

    await Future.delayed(Duration.zero, () {
      bindings.callReturningString(bindings.scanComputerStart!);
    });

    _pollTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _pollComputerProgress(),
    );
  }

  void stopComputerScan() {
    _pollTimer?.cancel();
    _pollTimer = null;

    final bindings = CoreBindings.instance;
    if (bindings.scanComputerStop != null) {
      bindings.callReturningString(bindings.scanComputerStop!);
    }

    _cancelled = true;
    final scanState = _state;
    final scanned = scanState is ScanRunning ? scanState.scanned : 0;
    _archiveAll();
    _state = ScanFinished(
      scanned: scanned,
      threatsFound: threats.length,
      elapsed: _computerStopwatch.elapsed,
    );
    _computerStopwatch.stop();
    notifyListeners();
  }

  void cancel() {
    if (_paused) {
      _paused = false;
      _pauseCompleter?.complete();
      _pauseCompleter = null;
    }
    _cancelled = true;
    if (_isComputerScan) {
      stopComputerScan();
    } else {
      final scanState = _state;
      final scanned = scanState is ScanRunning ? scanState.scanned : 0;
      _archiveAll();
      _state = ScanFinished(
        scanned: scanned,
        threatsFound: threats.length,
        elapsed: Duration.zero,
      );
      notifyListeners();
    }
  }

  void pause() {
    if (_state is! ScanRunning || _paused) return;
    _paused = true;
    _pauseCompleter = Completer<void>();
    if (_isComputerScan) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    _pauseCompleter?.complete();
    _pauseCompleter = null;
    if (_isComputerScan) {
      _pollTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => _pollComputerProgress(),
      );
    }
    notifyListeners();
  }

  void reset() {
    _cancelled = false;
    _paused = false;
    _pauseCompleter?.complete();
    _pauseCompleter = null;
    _results.clear();
    _isComputerScan = false;
    _computerScanDrive = '';
    _pollTimer?.cancel();
    _pollTimer = null;
    _state = const ScanIdle();
    notifyListeners();
  }


  Future<void> _ensureYaraReady() async {
    if (!CoreBindings.isInitialized) return;
    final b = CoreBindings.instance;
    if (b.getYaraStatus == null) return;
    try {
      await Future.delayed(Duration.zero,
          () => b.callReturningString(b.getYaraStatus!));
    } catch (_) {}
    try { await _service.scanFile('__warmup__'); } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollComputerProgress() async {
    final bindings = CoreBindings.instance;
    if (bindings.scanComputerGetProgress == null) return;
    if (_polling) return;
    _polling = true;

    try {
      final json = await Future.delayed(Duration.zero, () =>
          bindings.callReturningString(bindings.scanComputerGetProgress!));

      final data = jsonDecode(json) as Map<String, dynamic>;

      final isRunning  = data['is_running']    as bool?   ?? false;
      final isFinished = data['is_finished']   as bool?   ?? false;
      final total      = data['files_total']   as int?    ?? 0;
      final scanned    = data['files_scanned'] as int?    ?? 0;
      final threats    = data['threats_found'] as int?    ?? 0;
      final file       = data['current_file']  as String? ?? '';
      final drive      = data['current_drive'] as String? ?? '';

      _computerScanDrive = drive;

      _results.clear();
      final threatList = data['threats'] as List<dynamic>? ?? [];
      for (final t in threatList) {
        if (t is Map<String, dynamic>) {
          _results.add(ScanResult.fromJson(t));
        }
      }

      if (isFinished || !isRunning) {
        _pollTimer?.cancel();
        _pollTimer = null;
        _computerStopwatch.stop();
        _archiveAll();
        _state = ScanFinished(
          scanned: scanned,
          threatsFound: threats,
          elapsed: _computerStopwatch.elapsed,
        );
      } else {
        if (!_computerStopwatch.isRunning) _computerStopwatch.start();
        _state = ScanRunning(
          currentFile: file,
          scanned: scanned,
          total: total,
          threatsFound: threats,
        );
      }

      notifyListeners();
    } catch (e) { debugPrint('[MP] scan_controller error: $e');
    } finally {
      _polling = false;
    }
  }

  Future<void> _startScan(List<String> files) async {
    _cancelled = false;
    _results.clear();

    _state = ScanRunning(currentFile: files.isNotEmpty ? _shortName(files.first) : '', scanned: 0, total: files.length, threatsFound: 0);
    notifyListeners();

    await _ensureYaraReady();

    final stopwatch = Stopwatch()..start();
    int threatsFound = 0;

    for (int i = 0; i < files.length; i++) {
      if (_cancelled) break;

      if (_paused) {
        await _pauseCompleter?.future;
        if (_cancelled) break;
      }

      final file = files[i];

      _state = ScanRunning(currentFile: _shortName(file), scanned: i, total: files.length, threatsFound: threatsFound);
      notifyListeners();

      try {
        final result = await _service.scanFile(file);
        if (_cancelled) break;
        _results.add(result);
        if (result.isInfected) {
          threatsFound++;
          _state = ScanRunning(currentFile: _shortName(file), scanned: i + 1, total: files.length, threatsFound: threatsFound);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('[MP] scanFile error for $file: $e');
        if (_cancelled) break;
      }
    }

    if (_results.isEmpty && files.isNotEmpty && !_cancelled) {
      debugPrint('[MP] Primary scan yielded 0 results, retrying with fresh worker...');
      for (final file in files) {
        if (_cancelled) break;
        try {
          final result = await _service.scanFile(file);
          if (_cancelled) break;
          _results.add(result);
          if (result.isInfected) threatsFound++;
        } catch (e) {
          debugPrint('[MP] retry failed for $file: $e');
        }
      }
    }

    stopwatch.stop();

    if (_state is! ScanFinished) {
      _archiveAll();
      _state = ScanFinished(scanned: files.length, threatsFound: threatsFound, elapsed: stopwatch.elapsed);
      notifyListeners();
    }
  }

  void _archiveAll() {
    for (final r in _results) {
      ReportsArchiveService.instance
          .append(ArchivedReport.fromScanResult(r))
          .catchError((e) => debugPrint('[MP] archive append: $e'));
    }
  }

  Future<List<String>> _collectFiles(String dirPath) async {
    final dir = Directory(dirPath);
    final paths = <String>[];

    try {
      await for (final entity in dir.list(recursive: true)) {
        if (_cancelled) break;
        if (entity is File && !_shouldSkip(entity.path)) {
          paths.add(entity.path);
        }
      }
    } catch (e) { debugPrint('[MP] scan_controller error: $e'); }

    return paths;
  }

  static final _skipDirs = <String>{
    'quarantine',
    'logs',
  };
  static final _skipExtensions = <String>{
    '.msdb',
    '.yrc',
    '.log',
  };

  bool _shouldSkip(String filePath) {
    final normalized = filePath.replaceAll('\\', '/').toLowerCase();

    for (final dir in _skipDirs) {
      if (normalized.contains('/$dir/')) return true;
    }

    if (normalized.contains('/flutter_assets/')) return true;

    final ext = p.extension(normalized);
    if (_skipExtensions.contains(ext)) return true;

    final basename = p.basename(normalized);
    if (basename == 'mentoring_protector_core.dll') return true;

    return false;
  }

  String _shortName(String path) {
    return path.split(RegExp(r'[/\\]')).last;
  }
}

