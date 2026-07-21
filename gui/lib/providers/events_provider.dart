import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/home/widgets/events_list.dart';

class EventsProvider extends ChangeNotifier {
  final List<AppEvent> _appEvents = [];

  List<AppEvent> get appEvents => List.unmodifiable(_appEvents);

  EventsProvider() { _loadEvents(); }

  void addEvent(AppEvent event) {
    _appEvents.insert(0, event);
    if (_appEvents.length > 50) _appEvents.removeLast();
    _saveEvents();
    notifyListeners();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('app_events') ?? [];
    for (final json in raw) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        final messageKey = (map['messageKey'] as String?) ?? _migrateLegacyMessage(map['message'] as String?);
        if (messageKey == null) continue;
        _appEvents.add(AppEvent(type: EventType.values.byName(map['type'] as String? ?? ''), messageKey: messageKey, time: map['time'] as String? ?? ''));
      } catch (e) { debugPrint('[MP] FFI error: $e'); }
    }
    notifyListeners();
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _appEvents.take(50).map((e) => jsonEncode({ 'type': e.type.name, 'messageKey': e.messageKey, 'time': e.time })).toList();
    await prefs.setStringList('app_events', raw);
  }

  String? _migrateLegacyMessage(String? legacy) {
    if (legacy == null) return null;
    if (legacy == 'База обновлена' || legacy == 'Database updated') {
      return 'homeDbUpdated';
    }
    return null;
  }
}

