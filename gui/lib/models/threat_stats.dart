enum ThreatSource { scan, realtime, memory, web }

class DailyStats {
  final DateTime date;
  final int threats;
  final int scan;
  final int realtime;
  final int memory;
  final int web;

  const DailyStats({required this.date, this.threats = 0, this.scan = 0, this.realtime = 0, this.memory = 0, this.web = 0});

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String? ?? '2000-01-01'),
      threats: (json['threats'] as num?)?.toInt() ?? 0,
      scan: (json['scan'] as num?)?.toInt() ?? 0,
      realtime: (json['realtime'] as num?)?.toInt() ?? 0,
      memory: (json['memory'] as num?)?.toInt() ?? 0,
      web: (json['web'] as num?)?.toInt() ?? 0,
    );
  }
}

class ThreatStats {
  final int periodDays;
  final List<DailyStats> daily;
  final int total;

  const ThreatStats({this.periodDays = 30, this.daily = const [], this.total = 0});

  Map<ThreatSource, int> get bySource {
    int s = 0, r = 0, m = 0, w = 0;
    for (final d in daily) { s += d.scan; r += d.realtime; m += d.memory; w += d.web; }
    return { ThreatSource.scan: s, ThreatSource.realtime: r, ThreatSource.memory: m, ThreatSource.web: w };
  }

  factory ThreatStats.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) throw FormatException('Backend error: ${json['error']}');
    final rawDaily = json['daily'] as List<dynamic>? ?? [];
    return ThreatStats(
      periodDays: (json['period_days'] as num?)?.toInt() ?? 30,
      daily: rawDaily.whereType<Map<String, dynamic>>().map(DailyStats.fromJson).toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  static ThreatStats empty(int periodDays) => ThreatStats(periodDays: periodDays);
}
