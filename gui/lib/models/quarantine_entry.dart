
class QuarantineEntry {
  final String id;
  final String originalName;
  final String originalPath;
  final String threatName;
  final String threatType;
  final int dangerLevel;
  final String dateQuarantined;
  final int fileSize;
  final String detectionMethod;
  final bool isOrphan;

  const QuarantineEntry({required this.id, required this.originalName, required this.originalPath, required this.threatName, required this.threatType, required this.dangerLevel, required this.dateQuarantined, required this.fileSize, required this.detectionMethod, this.isOrphan = false});

  factory QuarantineEntry.fromJson(Map<String, dynamic> json) {
    return QuarantineEntry(
      id: json['id'] as String? ?? '',
      originalName: json['original_name'] as String? ?? '',
      originalPath: json['original_path'] as String? ?? '',
      threatName: json['threat_name'] as String? ?? '',
      threatType: json['threat_type'] as String? ?? '',
      dangerLevel: json['danger_level'] as int? ?? 0,
      dateQuarantined: json['date_quarantined'] as String? ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      detectionMethod: json['detection_method'] as String? ?? '',
      isOrphan: json['is_orphan'] as bool? ?? false,
    );
  }

  String get fileSizeLabel => switch (fileSize) { < 1024 => '$fileSize Б', < 1024 * 1024 => '${(fileSize / 1024).toStringAsFixed(1)} КБ', _ => '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} МБ' };
}
