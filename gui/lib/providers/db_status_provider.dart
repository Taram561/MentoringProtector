import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbStatusProvider extends ChangeNotifier {
  DateTime? _lastDbUpdate;
  bool _dbUpdating = false;

  DateTime? get lastDbUpdate => _lastDbUpdate;
  bool get dbUpdating => _dbUpdating;

  bool get dbIsOutdated {
    if (_lastDbUpdate == null) return true;
    return DateTime.now().difference(_lastDbUpdate!).inDays > 7;
  }

  DbStatusProvider() { _loadDbUpdateDate(); }

  void setDbUpdating(bool v) {
    _dbUpdating = v;
    notifyListeners();
  }

  void setDbUpdated() {
    _lastDbUpdate = DateTime.now();
    _dbUpdating = false;
    _saveDbUpdateDate();
    notifyListeners();
  }

  Future<void> _loadDbUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('last_db_update');
    if (ms != null) {
      _lastDbUpdate = DateTime.fromMillisecondsSinceEpoch(ms);
      notifyListeners();
    }
  }

  Future<void> _saveDbUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastDbUpdate != null) {
      await prefs.setInt('last_db_update', _lastDbUpdate!.millisecondsSinceEpoch);
    }
  }
}

