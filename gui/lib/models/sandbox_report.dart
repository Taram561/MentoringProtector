class BehavioralEvent {
  final String type;
  final String target;
  final String detail;
  final String timestamp;

  BehavioralEvent.fromJson(Map<String, dynamic> j) : type = j['type'] as String? ?? '', target = j['target'] as String? ?? '', detail = j['detail'] as String? ?? '', timestamp = j['timestamp'] as String? ?? '';
}

class SandboxReport {
  final bool completed;
  final int durationSeconds;
  final int riskScore;
  final bool timedOut;
  final List<String> riskIndicators;
  final List<BehavioralEvent> events;

  SandboxReport.fromJson(Map<String, dynamic> j) : completed = j['completed'] as bool? ?? false, durationSeconds = j['duration'] as int? ?? 0, riskScore = j['risk_score'] as int? ?? 0, timedOut = j['timed_out'] as bool? ?? false, riskIndicators = (j['risk_indicators'] as List?)?.map((e) => e.toString()).toList() ?? const [], events = (j['events'] as List?)?.map((e) => BehavioralEvent.fromJson(e as Map<String, dynamic>)).toList() ?? const [];

  SandboxReport.empty() : completed = false, durationSeconds = 0, riskScore = 0, timedOut = false, riskIndicators = const [], events = const [];
}
