import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../ffi/core_bindings.dart';
import '../ffi/service_interfaces.dart';

class ExclusionService implements IExclusionService {
  final CoreBindings _bindings;

  ExclusionService({CoreBindings? bindings}) : _bindings = bindings ?? CoreBindings.instance;

  @override
  Future<List<String>> getExclusions() async {
    if (_bindings.getExclusions == null) return const [];
    try {
      final json = _bindings.callReturningString(_bindings.getExclusions!);
      final data = jsonDecode(json) as Map<String, dynamic>;
      final list = data['exclusions'] as List?;
      return list?.map((e) => e.toString()).toList() ?? const [];
    } catch (e) {
      debugPrint('[MP] ExclusionService.getExclusions: $e');
      return const [];
    }
  }

  @override
  Future<bool> addExclusion(String path) async {
    if (_bindings.addExclusion == null) return false;
    try {
      final normalized = _normalizePath(path.trim());
      if (normalized == null) return false;
      final json = _bindings.callWithOneStringArg(_bindings.addExclusion!, normalized);
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      debugPrint('[MP] ExclusionService.addExclusion: $e');
      return false;
    }
  }

  @override
  Future<bool> removeExclusion(String path) async {
    if (_bindings.removeExclusion == null) return false;
    try {
      final json = _bindings.callWithOneStringArg(_bindings.removeExclusion!, path);
      final data = jsonDecode(json) as Map<String, dynamic>;
      return data['success'] == true;
    } catch (e) {
      debugPrint('[MP] ExclusionService.removeExclusion: $e');
      return false;
    }
  }

  String? _normalizePath(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('*.')) return trimmed;
    if (trimmed.startsWith(r'\\') || trimmed.startsWith(r'\??\')) return null;
    final canonical = p.canonicalize(trimmed);
    if (canonical.contains('..')) return null;
    if (RegExp(r'^[A-Za-z]:\\.*:').hasMatch(canonical)) return null;
    return canonical;
  }
}

