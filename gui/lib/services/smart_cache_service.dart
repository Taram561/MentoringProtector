import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../ffi/core_bindings.dart';
import '../ffi/service_interfaces.dart';

class SmartCacheService implements ISmartCacheService {
  final CoreBindings _bindings;

  SmartCacheService({CoreBindings? bindings}) : _bindings = bindings ?? CoreBindings.instance;

  @override
  bool get isAvailable => CoreBindings.isInitialized && _bindings.smartScanGetStats != null;

  @override
  Future<bool> invalidateCache() async {
    if (_bindings.smartScanInvalidate == null) return false;
    try {
      final json = _bindings.callReturningString(_bindings.smartScanInvalidate!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map['status'] == 'ok';
    } catch (e) {
      debugPrint('[MP] SmartCacheService.invalidateCache: $e');
      return false;
    }
  }

  @override
  Future<bool> clearCache() async {
    if (_bindings.smartScanClear == null) return false;
    try {
      final json = _bindings.callReturningString(_bindings.smartScanClear!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map['status'] == 'ok';
    } catch (e) {
      debugPrint('[MP] SmartCacheService.clearCache: $e');
      return false;
    }
  }
}

