class RealtimeEvent {
  final bool isThreat;
  final String verdict;
  final int score;
  final String action;
  final String filePath;
  final String threatName;
  final String detectedAt;

  const RealtimeEvent({required this.isThreat, required this.verdict, required this.score, required this.action, required this.filePath, required this.threatName, required this.detectedAt});

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    return RealtimeEvent(
      isThreat: json['is_threat'] as bool? ?? false,
      verdict: json['verdict'] as String? ?? 'clean',
      score: json['score'] as int? ?? 0,
      action: json['action'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      threatName: json['threat_name'] as String? ?? '',
      detectedAt: json['detected_at'] as String? ?? '',
    );
  }

  String get fileName {
    if (filePath.isEmpty) return '';
    final sep = filePath.contains('\\') ? '\\' : '/';
    return filePath.split(sep).last;
  }
}
