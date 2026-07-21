
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import '../ffi/core_bindings.dart';
import '../ffi/core_result.dart';
import '../ffi/service_interfaces.dart';
import '../models/scan_result.dart';

class ScanActionService implements IQuarantineService {
  final CoreBindings? _bindings;

  ScanActionService({CoreBindings? bindings}) : _bindings = bindings ?? (CoreBindings.isInitialized ? CoreBindings.instance : null);

  String _validatePath(String rawPath) {
    final trimmed = rawPath.trim();
    if (trimmed.startsWith(r'\\') || trimmed.startsWith(r'\??\')) throw Exception('Disallowed path prefix');
    final normalized = p.canonicalize(trimmed.replaceAll('/', '\\'));
    if (!RegExp(r'^[A-Za-z]:\\').hasMatch(normalized)) throw Exception('Not an absolute path: $normalized');
    if (normalized.contains('..')) throw Exception('Path traversal detected: $normalized');
    if (RegExp(r'^[A-Za-z]:\\.*:').hasMatch(normalized)) throw Exception('ADS path detected: $normalized');
    final lower = normalized.toLowerCase();
    const forbidden = ['\\windows\\', '\\system32\\', '\\program files\\', '\\program files (x86)\\', '\\mentoringprotector\\data\\', '\\mentoringprotector\\quarantine\\', '\\mentoringprotector\\logs\\'];
    if (forbidden.any((f) => lower.contains(f))) throw Exception('Protected directory: $normalized');
    return normalized;
  }

  @override
  Future<QuarantineOperationResult> quarantineFile({required ScanResult scanResult}) async {
    if (_bindings?.quarantineFile == null) return const QuarantineFailure(message: 'quarantine_file binding unavailable', statusCode: -1);
    try {
      _validatePath(scanResult.filePath);
    } catch (e) {
      return QuarantineFailure(message: '$e', statusCode: -2);
    }
    return using((arena) {
      final filePath = scanResult.filePath.toNativeUtf8(allocator: arena);
      final threatName = scanResult.threatName.toNativeUtf8(allocator: arena);
      final threatType = scanResult.threatType.toNativeUtf8(allocator: arena);
      final fileHash = scanResult.fileHash.toNativeUtf8(allocator: arena);
      final method = scanResult.detectionMethod.name.toNativeUtf8(allocator: arena);
      final ptr = _bindings!.quarantineFile!(filePath, threatName, threatType, scanResult.dangerLevel, fileHash, method);
      final json = ptr.toDartString();
      _bindings!.freeString(ptr);
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final success = map['success'] as bool? ?? false;
        if (success) return QuarantineSuccess(entryId: map['entry_id']?.toString() ?? '');
        return QuarantineFailure(message: map['message']?.toString() ?? 'quarantine failed', statusCode: (map['status_code'] as int?) ?? -3);
      } catch (e) {
        return QuarantineFailure(message: 'parse error: $e', statusCode: -4);
      }
    });
  }

  @override
  Future<QuarantineOperationResult> restoreFile(String entryId) async {
    if (_bindings?.restoreFile == null) return const QuarantineFailure(message: 'restore_file binding unavailable', statusCode: -1);
    try {
      final json = _bindings!.callWithOneStringArg(_bindings!.restoreFile!, entryId);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final success = map['success'] as bool? ?? false;
      if (success) return QuarantineSuccess(entryId: entryId);
      return QuarantineFailure(message: map['message']?.toString() ?? 'restore failed', statusCode: (map['status_code'] as int?) ?? -3);
    } catch (e) {
      return QuarantineFailure(message: '$e', statusCode: -4);
    }
  }

  @override
  Future<QuarantineOperationResult> deleteFile(String entryId) async {
    if (_bindings?.deleteFromQuarantine == null) return const QuarantineFailure(message: 'delete_from_quarantine binding unavailable', statusCode: -1);
    try {
      final json = _bindings!.callWithOneStringArg(_bindings!.deleteFromQuarantine!, entryId);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final success = map['success'] as bool? ?? false;
      if (success) return QuarantineSuccess(entryId: entryId);
      return QuarantineFailure(message: map['message']?.toString() ?? 'delete failed', statusCode: (map['status_code'] as int?) ?? -3);
    } catch (e) {
      return QuarantineFailure(message: '$e', statusCode: -4);
    }
  }

  @override
  Future<QuarantineList> getQuarantineList() async {
    if (_bindings?.getQuarantineList == null) return QuarantineList.empty();
    try {
      final json = _bindings!.callReturningString(_bindings!.getQuarantineList!);
      if (json.isEmpty) return QuarantineList.empty();
      final map = jsonDecode(json) as Map<String, dynamic>;
      return QuarantineList.fromJson(map);
    } catch (e) {
      debugPrint('[MP] ScanActionService getQuarantineList: $e');
      return QuarantineList.empty();
    }
  }

  Future<void> deletePhysicalFile(String filePath) async {
    final safePath = _validatePath(filePath);
    File(safePath).deleteSync();
  }
}
