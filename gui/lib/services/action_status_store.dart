import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum IncidentStatus { pending, quarantined, deleted, whitelisted, ignored }

class ActionStatusStore {
  static const _prefsKey = 'mp_action_status_map';

  static final ActionStatusStore instance = ActionStatusStore._();
  ActionStatusStore._();

  Future<Map<String, IncidentStatus>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return {};
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, _fromString(v as String)));
    } catch (e) {
      debugPrint('[ActionStatusStore] loadAll: $e');
      return {};
    }
  }

  Future<void> setStatus(String reportKey, IncidentStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      final map = raw != null ? (jsonDecode(raw) as Map<String, dynamic>) : <String, dynamic>{};
      map[reportKey] = _toString(status);
      await prefs.setString(_prefsKey, jsonEncode(map));
    } catch (e) {
      debugPrint('[ActionStatusStore] setStatus: $e');
    }
  }

  Future<IncidentStatus> getStatus(String reportKey) async {
    final all = await loadAll();
    return all[reportKey] ?? IncidentStatus.pending;
  }

  static String _toString(IncidentStatus s) => s.name;

  static IncidentStatus _fromString(String s) => IncidentStatus.values.firstWhere((v) => v.name == s, orElse: () => IncidentStatus.pending);
}

