
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  static const _storageKey = 'mp_user_profile';
  static const int _maxHygieneHistory = 30;

  UserProfile _profile = UserProfile();
  bool _loaded = false;

  UserProfileProvider() {
    _load();
  }


  UserProfile get profile => _profile;
  bool get loaded => _loaded;
  bool get onboardingCompleted => _profile.onboardingCompleted;
  UserLevel get level => _profile.level;
  int get riskScore => _profile.riskScore;
  RiskTier get riskTier => _profile.riskTier;
  String get protectionGoal => _profile.protectionGoal;
  List<RiskEvent> get recentEvents => (_profile.events.where((e) => e.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 30)))).toList())..sort((a, b) => b.timestamp.compareTo(a.timestamp));


  Future<void> completeOnboarding({required UserLevel level, required String goal}) async {
    _profile.level = level;
    _profile.protectionGoal = goal;
    _profile.onboardingCompleted = true;
    await _save();
    notifyListeners();
  }


  Future<void> recordEvent(RiskEventType type, {String detail = ''}) async {
    _profile.addEvent(RiskEvent(type: type, timestamp: DateTime.now(), detail: detail));
    await _save();
    notifyListeners();
  }


  Future<void> setLevel(UserLevel level) async {
    _profile.level = level;
    await _save();
    notifyListeners();
  }


  Set<String> get completedTips => _profile.completedTips;
  List<HygieneSnapshot> get hygieneHistory => _profile.hygieneHistory;
  Map<String, QuizResult> get quizResults => _profile.quizResults;

  Future<void> saveQuizResult(String tipId, int correct, int total) async {
    final existing = _profile.quizResults[tipId];
    final newResult = QuizResult(correct: correct, total: total, date: DateTime.now());
    if (existing == null || newResult.ratio >= existing.ratio) {
      _profile.quizResults[tipId] = newResult;
    }
    await _save();
    notifyListeners();
  }

  Future<void> markTipCompleted(String tipId) async {
    _profile.completedTips.add(tipId);
    await _save();
    notifyListeners();
  }

  Future<void> markTipIncomplete(String tipId) async {
    _profile.completedTips.remove(tipId);
    await _save();
    notifyListeners();
  }


  Set<int> getSeenQuestions(String tipId) =>
      _profile.seenQuizQuestions[tipId] ?? {};

  Future<void> markQuestionsShown(String tipId, List<int> shownIndices, int totalInQuiz) async {
    final seen = _profile.seenQuizQuestions[tipId] ?? <int>{};
    seen.addAll(shownIndices);

    if (seen.length >= totalInQuiz) {
      _profile.seenQuizQuestions.remove(tipId);
    } else {
      _profile.seenQuizQuestions[tipId] = seen;
    }

    await _save();
    notifyListeners();
  }

  Future<void> resetQuizzesIfMonthPassed() async {
    if (_profile.completedTips.isEmpty) return;

    final now = DateTime.now();
    final lastQuiz = _profile.lastQuizReset;
    if (lastQuiz != null && now.difference(lastQuiz).inDays < 30) return;

    _profile.completedTips.clear();
    _profile.lastQuizReset = now;
    await _save();
    notifyListeners();
  }

  Future<void> snapshotHygieneIndex(int currentIndex) async {
    final today = DateTime.now();
    final history = _profile.hygieneHistory;

    if (history.isNotEmpty) {
      final last = history.last.date;
      if (last.year == today.year && last.month == today.month && last.day == today.day) return;
    }

    history.add(HygieneSnapshot(score: currentIndex, date: today));

    if (history.length > _maxHygieneHistory) {
      _profile.hygieneHistory = history.sublist(history.length - _maxHygieneHistory);
    }

    await _save();
    notifyListeners();
  }


  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(json);
      }
    } catch (e) {
      debugPrint('[MP] UserProfile load error: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_profile.toJson());
      await prefs.setString(_storageKey, json);
    } catch (e) {
      debugPrint('[MP] UserProfile save error: $e');
    }
  }
}

