class DailyScan {
  final DateTime date;
  final int scans;
  final int filesScanned;

  const DailyScan({required this.date, this.scans = 0, this.filesScanned = 0});

  factory DailyScan.fromJson(Map<String, dynamic> json) {
    return DailyScan(
      date: DateTime.parse(json['date'] as String? ?? '2000-01-01'),
      scans: (json['scans'] as num?)?.toInt() ?? 0,
      filesScanned: (json['files_scanned'] as num?)?.toInt() ?? 0,
    );
  }
}

class ScanHistory {
  final int periodDays;
  final List<DailyScan> daily;
  final int totalScans;
  final int totalFiles;

  const ScanHistory({this.periodDays = 30, this.daily = const [], this.totalScans = 0, this.totalFiles = 0});

  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) throw FormatException('Backend error: ${json['error']}');
    final rawDaily = json['daily'] as List<dynamic>? ?? [];
    return ScanHistory(
      periodDays: (json['period_days'] as num?)?.toInt() ?? 30,
      daily: rawDaily.whereType<Map<String, dynamic>>().map(DailyScan.fromJson).toList(),
      totalScans: (json['total_scans'] as num?)?.toInt() ?? 0,
      totalFiles: (json['total_files'] as num?)?.toInt() ?? 0,
    );
  }

  static ScanHistory empty(int periodDays) => ScanHistory(periodDays: periodDays);
}
