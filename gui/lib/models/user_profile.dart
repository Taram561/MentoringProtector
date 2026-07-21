
enum UserLevel {
  beginner, regular, advanced;

  String get id => name;
  static UserLevel fromId(String id) => switch (id) { 'beginner' => UserLevel.beginner, 'advanced' => UserLevel.advanced, _ => UserLevel.regular };
}

enum RiskTier {
  safe, cautious, risky, dangerous;

  static RiskTier fromScore(int score) => switch (score) { < 20 => RiskTier.safe, < 40 => RiskTier.cautious, < 70 => RiskTier.risky, _ => RiskTier.dangerous };
}

enum RiskEventType {
  webWarningIgnored(weight: 15), scanThreatIgnored(weight: 20), protectionDisabled(weight: 10), dangerousDownload(weight: 25), lessonCompleted(weight: -10), protectionEnabled(weight: -5), threatQuarantined(weight: -8), quizWrongAnswer(weight: 2), archiveThreatFound(weight: 18), threatWhitelisted(weight: -3), securityNudgeIgnored(weight: 5), nudgeEngaged(weight: -2);

  final int weight;
  const RiskEventType({required this.weight});

  String get id => name;

  static RiskEventType? fromId(String id) {
    for (final v in values) {
      if (v.name == id) return v;
    }
    return null;
  }
}

class RiskEvent {
  final RiskEventType type;
  final DateTime timestamp;
  final String detail;

  const RiskEvent({required this.type, required this.timestamp, this.detail = ''});

  Map<String, dynamic> toJson() => { 'type': type.id, 'ts': timestamp.millisecondsSinceEpoch, if (detail.isNotEmpty) 'detail': detail };

  static RiskEvent? fromJson(Map<String, dynamic> json) {
    final type = RiskEventType.fromId(json['type'] as String? ?? '');
    if (type == null) return null;
    return RiskEvent(type: type, timestamp: DateTime.fromMillisecondsSinceEpoch(json['ts'] as int? ?? 0), detail: json['detail'] as String? ?? '');
  }
}

class QuizResult {
  final int correct;
  final int total;
  final DateTime date;

  const QuizResult({required this.correct, required this.total, required this.date});

  double get ratio => total > 0 ? correct / total : 0;
  bool get isPerfect => correct == total;

  Map<String, dynamic> toJson() => { 'c': correct, 't': total, 'd': date.millisecondsSinceEpoch };

  static QuizResult fromJson(Map<String, dynamic> json) => QuizResult(correct: json['c'] as int? ?? 0, total: json['t'] as int? ?? 0, date: DateTime.fromMillisecondsSinceEpoch(json['d'] as int? ?? 0));
}

class HygieneSnapshot {
  final int score;
  final DateTime date;

  const HygieneSnapshot({required this.score, required this.date});

  Map<String, dynamic> toJson() => { 's': score, 'd': date.millisecondsSinceEpoch };

  static HygieneSnapshot fromJson(Map<String, dynamic> json) => HygieneSnapshot(score: json['s'] as int? ?? 50, date: DateTime.fromMillisecondsSinceEpoch(json['d'] as int? ?? 0));
}

class UserProfile {
  UserLevel level;
  bool onboardingCompleted;
  DateTime createdAt;
  List<RiskEvent> events;
  String protectionGoal;
  Set<String> completedTips;
  List<HygieneSnapshot> hygieneHistory;
  DateTime? lastQuizReset;
  Map<String, QuizResult> quizResults;
  Map<String, Set<int>> seenQuizQuestions;

  UserProfile({this.level = UserLevel.regular, this.onboardingCompleted = false, DateTime? createdAt, List<RiskEvent>? events, this.protectionGoal = '', Set<String>? completedTips, List<HygieneSnapshot>? hygieneHistory, this.lastQuizReset, Map<String, QuizResult>? quizResults, Map<String, Set<int>>? seenQuizQuestions}) : createdAt = createdAt ?? DateTime.now(), events = events ?? [], completedTips = completedTips ?? {}, hygieneHistory = hygieneHistory ?? [], quizResults = quizResults ?? {}, seenQuizQuestions = seenQuizQuestions ?? {};

  int get riskScore {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recentWeight = events.where((e) => e.timestamp.isAfter(cutoff)).fold<int>(0, (sum, e) => sum + e.type.weight);
    return recentWeight.clamp(0, 100);
  }

  RiskTier get riskTier => RiskTier.fromScore(riskScore);

  int get positiveActions => events.where((e) => e.type.weight < 0).length;
  int get riskyActions => events.where((e) => e.type.weight > 0).length;

  static const int _maxRiskEvents = 200;

  void addEvent(RiskEvent event) {
    events.add(event);
    if (events.length > _maxRiskEvents) events = events.sublist(events.length - _maxRiskEvents);
  }

  Map<String, dynamic> toJson() => { 'level': level.id, 'onboarding': onboardingCompleted, 'created': createdAt.millisecondsSinceEpoch, 'goal': protectionGoal, 'events': events.map((e) => e.toJson()).toList(), 'completedTips': completedTips.toList(), 'hygieneHistory': hygieneHistory.map((s) => s.toJson()).toList(), if (lastQuizReset != null) 'lastQuizReset': lastQuizReset!.millisecondsSinceEpoch, 'quizResults': quizResults.map((k, v) => MapEntry(k, v.toJson())), 'seenQuizQ': seenQuizQuestions.map((k, v) => MapEntry(k, v.toList())) };

  static UserProfile fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];
    final events = rawEvents.map((e) => RiskEvent.fromJson(e as Map<String, dynamic>)).whereType<RiskEvent>().toList();
    final rawTips = json['completedTips'] as List<dynamic>? ?? [];
    final rawHistory = json['hygieneHistory'] as List<dynamic>? ?? [];
    final rawQuizResults = json['quizResults'] as Map<String, dynamic>? ?? {};
    final quizResults = rawQuizResults.map((k, v) => MapEntry(k, QuizResult.fromJson(v as Map<String, dynamic>)));
    final rawSeenQ = json['seenQuizQ'] as Map<String, dynamic>? ?? {};
    final seenQuizQuestions = rawSeenQ.map((k, v) => MapEntry(k, (v as List<dynamic>).map((e) => e as int).toSet()));
    return UserProfile(level: UserLevel.fromId(json['level'] as String? ?? 'regular'), onboardingCompleted: json['onboarding'] as bool? ?? false, createdAt: DateTime.fromMillisecondsSinceEpoch(json['created'] as int? ?? DateTime.now().millisecondsSinceEpoch), events: events, protectionGoal: json['goal'] as String? ?? '', completedTips: rawTips.map((e) => e.toString()).toSet(), hygieneHistory: rawHistory.map((e) => HygieneSnapshot.fromJson(e as Map<String, dynamic>)).toList(), lastQuizReset: json['lastQuizReset'] != null ? DateTime.fromMillisecondsSinceEpoch(json['lastQuizReset'] as int) : null, quizResults: quizResults, seenQuizQuestions: seenQuizQuestions);
  }
}
