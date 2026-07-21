
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../ffi/app_paths.dart';
import '../models/archived_report.dart';

class ReportsArchiveService extends ChangeNotifier {
  ReportsArchiveService._();
  static final ReportsArchiveService instance = ReportsArchiveService._();

  static const int _maxRecords = 10000;
  static const int _keepRecords = 5000;

  Future<void> _writeLock = Future.value();

  final Set<String> _dedupCache = {};
  bool _cacheLoaded = false;

  String get _archivePath {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.join(localAppData, 'MentoringProtector', 'reports', 'archive.jsonl');
    }
    return p.join(AppPaths.projectRoot, 'reports', 'archive.jsonl');
  }

  Future<void> _ensureDir() async {
    final dir = Directory(p.dirname(_archivePath));
    if (!dir.existsSync()) await dir.create(recursive: true);
  }

  Future<void> _loadDedupCache() async {
    if (_cacheLoaded) return;
    _cacheLoaded = true;
    try {
      final file = File(_archivePath);
      if (!file.existsSync()) return;
      for (final raw in await file.readAsLines()) {
        if (raw.trim().isEmpty) continue;
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final path = map['file_path'] as String? ?? '';
          final extras = map['scan_extras'] as Map<String, dynamic>?;
          final hash = extras?['file_hash'] as String? ?? '';
          if (path.isNotEmpty && hash.isNotEmpty) {
            _dedupCache.add('$path\x00$hash');
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[MP] ReportsArchiveService._loadDedupCache: $e');
    }
  }

  Future<void> append(ArchivedReport report) {
    final completer = Completer<void>();
    _writeLock = _writeLock.then((_) async {
      try {
        await _loadDedupCache();
        if (report.type == ArchivedReportType.scan) {
          final hash = report.scanExtras?['file_hash'] as String? ?? '';
          if (hash.isNotEmpty) {
            final key = '${report.filePath}\x00$hash';
            if (_dedupCache.contains(key)) {
              completer.complete();
              return;
            }
            _dedupCache.add(key);
          }
        }
        await _ensureDir();
        final file = File(_archivePath);
        final line = jsonEncode(report.toJson());
        await file.writeAsString('$line\n', mode: FileMode.append, flush: false);
        await _rotateIfNeeded(file);
        notifyListeners();
        completer.complete();
      } catch (e) {
        debugPrint('[MP] ReportsArchiveService.append: $e');
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> cleanDuplicates() {
    final completer = Completer<void>();
    _writeLock = _writeLock.then((_) async {
      try {
        final all = await loadAll();
        final seen = <String>{};
        final unique = <ArchivedReport>[];
        for (final r in all) {
          final hash = r.scanExtras?['file_hash'] as String? ?? '';
          final key = hash.isNotEmpty ? '${r.filePath}\x00$hash' : r.id;
          if (seen.add(key)) unique.add(r);
        }
        if (unique.length < all.length) {
          await _rewriteFile(unique);
          _cacheLoaded = false;
          _dedupCache.clear();
        }
        completer.complete();
      } catch (e) {
        debugPrint('[MP] ReportsArchiveService.cleanDuplicates: $e');
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<List<ArchivedReport>> loadAll({int? limit}) async {
    try {
      final file = File(_archivePath);
      if (!file.existsSync()) return [];
      final lines = await file.readAsLines();
      final reports = <ArchivedReport>[];
      for (final raw in lines) {
        if (raw.trim().isEmpty) continue;
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          reports.add(ArchivedReport.fromJson(map));
        } catch (e) {
          debugPrint('[MP] ReportsArchiveService: skipping corrupt line: $e');
        }
      }
      reports.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (limit != null && reports.length > limit) {
        return reports.take(limit).toList();
      }
      return reports;
    } catch (e) {
      debugPrint('[MP] ReportsArchiveService.loadAll: $e');
      return [];
    }
  }

  Future<List<ArchivedReport>> search({String? query, ArchivedReportType? type, int minDangerLevel = 0}) async {
    final all = await loadAll();
    final q = query?.trim().toLowerCase() ?? '';
    return all.where((r) {
      if (type != null && r.type != type) return false;
      if (r.dangerLevel < minDangerLevel) return false;
      if (q.isNotEmpty) {
        final hay = '${r.fileName} ${r.threatName} ${r.filePath}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> deleteOne(String id) {
    final completer = Completer<void>();
    _writeLock = _writeLock.then((_) async {
      try {
        final all = await loadAll();
        all.removeWhere((r) => r.id == id);
        await _rewriteFile(all);
        notifyListeners();
        completer.complete();
      } catch (e) {
        debugPrint('[MP] ReportsArchiveService.deleteOne: $e');
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> clear() {
    final completer = Completer<void>();
    _writeLock = _writeLock.then((_) async {
      try {
        final file = File(_archivePath);
        if (file.existsSync()) await file.delete();
        notifyListeners();
        completer.complete();
      } catch (e) {
        debugPrint('[MP] ReportsArchiveService.clear: $e');
        completer.complete();
      }
    });
    return completer.future;
  }

  Future<void> _rotateIfNeeded(File file) async {
    try {
      final lines = await file.readAsLines();
      if (lines.length <= _maxRecords) return;
      final keep = lines.skip(lines.length - _keepRecords).toList();
      await file.writeAsString('${keep.join('\n')}\n', flush: true);
    } catch (e) {
      debugPrint('[MP] ReportsArchiveService.rotate: $e');
    }
  }

  Future<void> _rewriteFile(List<ArchivedReport> reports) async {
    final file = File(_archivePath);
    if (reports.isEmpty) {
      if (file.existsSync()) await file.delete();
      return;
    }
    final buf = StringBuffer();
    for (final r in reports.reversed) {
      buf.writeln(jsonEncode(r.toJson()));
    }
    await file.writeAsString(buf.toString(), flush: true);
  }
}

