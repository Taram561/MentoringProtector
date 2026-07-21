import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import '../ffi/app_paths.dart';
import '../ffi/core_bindings.dart';

class DbUpdateResult {
  final bool success;
  final String message;
  final bool usedFallback;
  const DbUpdateResult({required this.success, required this.message, this.usedFallback = false});
}

class DartCvdDownloader {
  static const String _cvdUrl = 'https://database.clamav.net/daily.cvd';
  static const int _cvdHeaderSize = 512;

  static Future<DbUpdateResult> fetchAndApply() async {
    try {
      final result = await _downloadAndParse();
      if (result.success) return result;
    } catch (e) {
      debugLog('CVD parse failed: $e - falling back to Python');
    }
    return _fallbackPython();
  }


  static Future<DbUpdateResult> _downloadAndParse() async {
    final response = await http.get(Uri.parse(_cvdUrl)).timeout(const Duration(seconds: 120));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final bytes = response.bodyBytes;
    if (bytes.length <= _cvdHeaderSize) {
      throw Exception('CVD file too small (${bytes.length} bytes)');
    }

    final header = ascii.decode(bytes.sublist(0, _cvdHeaderSize), allowInvalid: true);
    final parts = header.split(':');
    if (parts.length < 6 || parts[0].trim() != 'ClamAV-VDB') {
      throw Exception('Not a valid ClamAV CVD header');
    }

    final headerMd5 = parts[5].trim().replaceAll('\x00', '');
    final payload = bytes.sublist(_cvdHeaderSize);
    final actualMd5 = _md5Hex(payload);
    if (headerMd5.isNotEmpty && actualMd5 != headerMd5) {
      throw Exception('CVD MD5 mismatch: expected=$headerMd5 actual=$actualMd5');
    }

    final decompressed = BZip2Decoder().decodeBytes(payload);
    final archive = TarDecoder().decodeBytes(decompressed);

    final buffer = StringBuffer();
    int sigCount = 0;
    for (final file in archive) {
      final name = file.name;
      if (!name.endsWith('.hdb') && !name.endsWith('.hsb')) continue;
      if (!file.isFile) continue;

      final content = utf8.decode(file.content as List<int>, allowMalformed: true);
      for (final line in content.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        if (trimmed.contains(':') && (trimmed.endsWith(':Andr.') || trimmed.contains(':Andr.') || trimmed.contains(':Android.'))) continue;
        buffer.writeln(trimmed);
        sigCount++;
      }
    }

    if (sigCount == 0) {
      throw Exception('No signatures extracted from CVD archive');
    }

    final msdbContent = buffer.toString();
    final msdbBytes = Uint8List.fromList(utf8.encode(msdbContent));
    final sha256hex = _sha256Hex(msdbBytes);

    final sigPath = AppPaths.signaturesPath;
    final tmpPath = '$sigPath.tmp';
    await File(tmpPath).writeAsString(msdbContent, encoding: utf8);
    await File(tmpPath).rename(sigPath);

    try {
      final versionPath = p.join(p.dirname(sigPath), 'signatures_version.txt');
      final versionTmpPath = '$versionPath.tmp';
      final now = DateTime.now().toLocal().toString().substring(0, 19);
      await File(versionTmpPath).writeAsString('last_updated=$now\nsignature_count=$sigCount\nsource=ClamAV\nsignatures_sha256=$sha256hex\n', encoding: utf8);
      await File(versionTmpPath).rename(versionPath);
      final markerPath = p.join(p.dirname(sigPath), '.pin_required');
      await File(markerPath).writeAsString('1', encoding: utf8);
    } catch (e) {
      debugLog('SHA-256 pin write failed: $e');
    }

    try {
      await _verifyIntegrity();
    } catch (e) {
      debugLog('Integrity check failed before FFI reload: $e');
      return DbUpdateResult(success: false, message: 'Signature integrity check failed: $e');
    }

    final reloaded = _ffiReload();

    return DbUpdateResult(success: true, message: 'Updated: $sigCount signatures loaded${reloaded ? '' : ' (FFI reload skipped - core not ready)'}');
  }


  static Future<String?> verifySignaturesOnStartup() async {
    final sigPath = AppPaths.signaturesPath;
    if (!File(sigPath).existsSync()) return null;

    final dataDir = p.dirname(sigPath);
    final markerPath = p.join(dataDir, '.pin_required');
    if (!File(markerPath).existsSync()) {
      final versionPath = p.join(dataDir, 'signatures_version.txt');
      String versionContent = '';
      try {
        versionContent = await File(versionPath).readAsString(encoding: utf8);
      } catch (_) {}
      if (!versionContent.contains('signatures_sha256=')) {
        await _bootstrapPin();
      }
    }

    try {
      await _verifyIntegrity();
      return null;
    } catch (e) {
      return 'Signature database integrity check failed: $e';
    }
  }

  static Future<void> _bootstrapPin() async {
    try {
      final sigPath = AppPaths.signaturesPath;
      final dataDir = p.dirname(sigPath);
      final versionPath = p.join(dataDir, 'signatures_version.txt');
      final markerPath = p.join(dataDir, '.pin_required');

      final actualBytes = await File(sigPath).readAsBytes();
      final sha256hex = _sha256Hex(actualBytes);

      String existing = '';
      try {
        existing = await File(versionPath).readAsString(encoding: utf8);
      } catch (_) {}

      final lines = existing.split('\n').where((l) => l.isNotEmpty && !l.startsWith('signatures_sha256=')).toList();
      lines.add('signatures_sha256=$sha256hex');
      await File(versionPath).writeAsString('${lines.join('\n')}\n', encoding: utf8);
      await File(markerPath).writeAsString('1', encoding: utf8);
      debugPrint('[MP] Signatures pin bootstrapped: $sha256hex');
    } catch (e) {
      debugPrint('[MP] Bootstrap pin failed (non-critical): $e');
    }
  }


  static Future<DbUpdateResult> _fallbackPython() async {
    final scriptPath = p.join(AppPaths.projectRoot, 'updater', 'fetch_signatures.py');
    ProcessResult? result;
    for (final exe in ['python', 'python3', 'py']) {
      try {
        result = await Process.run(exe, [scriptPath]);
        break;
      } on ProcessException {
        continue;
      }
    }

    if (result == null) {
      return const DbUpdateResult(success: false, message: 'No Python interpreter found and CVD download failed', usedFallback: true);
    }

    if (result.exitCode != 0) {
      return DbUpdateResult(success: false, message: 'Python updater failed (exit ${result.exitCode}): ${result.stderr}', usedFallback: true);
    }

    _ffiReload();
    return const DbUpdateResult(success: true, message: 'Updated via Python fallback', usedFallback: true);
  }


  static Future<void> _verifyIntegrity() async {
    final sigPath = AppPaths.signaturesPath;
    final dataDir = p.dirname(sigPath);
    final versionPath = p.join(dataDir, 'signatures_version.txt');
    final markerPath = p.join(dataDir, '.pin_required');

    final pinRequired = File(markerPath).existsSync();

    String versionContent;
    try {
      versionContent = await File(versionPath).readAsString(encoding: utf8);
    } on FileSystemException {
      if (pinRequired) {
        throw Exception('PIN REQUIRED but signatures_version.txt missing - possible tampering');
      }
      return;
    }

    final pinLine = versionContent.split('\n').firstWhere((l) => l.startsWith('signatures_sha256='), orElse: () => '');

    if (pinLine.isEmpty) {
      if (pinRequired) {
        throw Exception('PIN REQUIRED but signatures_sha256= entry missing - possible tampering');
      }
      return;
    }

    final pinHash = pinLine.substring('signatures_sha256='.length).trim();
    if (pinHash.isEmpty || pinHash.length != 64) {
      throw Exception('signatures_sha256 is malformed (${pinHash.length} chars)');
    }

    final actualBytes = await File(sigPath).readAsBytes();
    final actualHash = _sha256Hex(actualBytes);

    if (actualHash != pinHash) {
      throw Exception('SHA-256 mismatch: stored=$pinHash actual=$actualHash');
    }
  }

  static bool _ffiReload() {
    try {
      if (!CoreBindings.isInitialized) return false;
      final b = CoreBindings.instance;
      if (b.reloadSignatures != null) {
        return b.reloadSignatures!() == 1;
      }
    } catch (e) { debugPrint('[MP] DartCvdDownloader FFI reload: $e'); }
    return false;
  }

  static String _md5Hex(Uint8List data) => md5.convert(data).toString();

  static String _sha256Hex(Uint8List data) => sha256.convert(data).toString();

  static void debugLog(String msg) {
    print('[MP DbUpdater] $msg');
  }
}

