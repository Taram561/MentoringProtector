import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../ffi/core_bindings.dart';
import '../ffi/service_interfaces.dart';

class VulnService implements IVulnService {
  final CoreBindings _bindings;

  VulnService({CoreBindings? bindings}) : _bindings = bindings ?? CoreBindings.instance;

  @override
  Future<String?> getFixDescriptor(String vulnId) async {
    if (!CoreBindings.isInitialized) return null;
    if (_bindings.getVulnFixDescriptor == null) return null;
    try {
      final json = _bindings.callWithOneStringArg(_bindings.getVulnFixDescriptor!, vulnId);
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map['helper_arg'] as String?;
    } catch (e) {
      debugPrint('[MP] VulnService.getFixDescriptor: $e');
      return null;
    }
  }
}

