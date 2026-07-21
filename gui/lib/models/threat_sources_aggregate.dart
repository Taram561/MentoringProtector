class ThreatSourcesAggregate {
  final int periodDays;
  final int scan;
  final int realtime;
  final int memory;
  final int web;
  final int total;

  const ThreatSourcesAggregate({this.periodDays = 30, this.scan = 0, this.realtime = 0, this.memory = 0, this.web = 0, this.total = 0});

  factory ThreatSourcesAggregate.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) throw FormatException('Backend error: ${json['error']}');
    return ThreatSourcesAggregate(
      periodDays: (json['period_days'] as num?)?.toInt() ?? 30,
      scan: (json['scan'] as num?)?.toInt() ?? 0,
      realtime: (json['realtime'] as num?)?.toInt() ?? 0,
      memory: (json['memory'] as num?)?.toInt() ?? 0,
      web: (json['web'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  static ThreatSourcesAggregate empty(int periodDays) => ThreatSourcesAggregate(periodDays: periodDays);
}
