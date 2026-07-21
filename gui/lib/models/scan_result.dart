import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../theme/app_theme.dart';
import 'threat_info.dart';
import 'heuristic_result.dart';

enum DetectionMethod { signature, yara, heuristic, archiveScan, clean }

enum SeverityLevel {
  info, warning, high, critical;

  static SeverityLevel fromDangerLevel(int level) => switch (level) { <= 2 => SeverityLevel.info, <= 5 => SeverityLevel.warning, <= 8 => SeverityLevel.high, _ => SeverityLevel.critical };

  String get label => switch (this) { info => 'Info', warning => 'Warning', high => 'High', critical => 'Critical' };

  String labelOf(AppLocalizations l10n) => switch (this) { info => l10n.severityLabelInfo, warning => l10n.severityLabelWarning, high => l10n.severityLabelHigh, critical => l10n.severityLabelCritical };

  Color get color => switch (this) { info => AppColors.primary, warning => AppColors.severityMedium, high => AppColors.severityHigh, critical => AppColors.severityCritical };

  Color adaptiveColor(AdaptiveColors c) => switch (this) { info => c.primary, warning => c.severityMedium, high => c.severityHigh, critical => c.severityCritical };

  IconData get icon => switch (this) { info => Icons.info_outline, warning => Icons.warning_amber_rounded, high => Icons.error_outline, critical => Icons.dangerous };
}

class ScanResult {
  final bool isInfected;
  final String filePath;
  final String fileHash;
  final String threatName;
  final String threatType;
  final int dangerLevel;
  final ThreatInfo threatInfo;
  final HeuristicResult heuristic;
  final DetectionMethod detectionMethod;
  final List<String> enginesTriggered;

  const ScanResult({
    required this.isInfected,
    required this.filePath,
    required this.fileHash,
    required this.threatName,
    required this.threatType,
    required this.dangerLevel,
    required this.threatInfo,
    required this.heuristic,
    required this.detectionMethod,
    this.enginesTriggered = const [],
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final isInfected = json['is_infected'] as bool? ?? false;
    return ScanResult(
      isInfected: isInfected,
      filePath: json['file_path'] as String? ?? '',
      fileHash: json['file_hash'] as String? ?? '',
      threatName: json['threat_name'] as String? ?? '',
      threatType: json['threat_type'] as String? ?? '',
      dangerLevel: json['danger_level'] as int? ?? 0,
      threatInfo: isInfected ? ThreatInfo.fromJson(json) : ThreatInfo.empty(),
      heuristic: HeuristicResult.fromJson(json),
      detectionMethod: _parseDetectionMethod(json['detection_method'] as String?),
      enginesTriggered: (json['engines_triggered'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  factory ScanResult.empty(String filePath) {
    return ScanResult(
      isInfected: false,
      filePath: filePath,
      fileHash: '',
      threatName: '',
      threatType: '',
      dangerLevel: 0,
      threatInfo: ThreatInfo.empty(),
      heuristic: HeuristicResult.empty(),
      detectionMethod: DetectionMethod.clean,
    );
  }

  SeverityLevel get severity => SeverityLevel.fromDangerLevel(dangerLevel);

  String? get archiveInnerPath {
    if (detectionMethod != DetectionMethod.archiveScan) return null;
    final start = threatName.lastIndexOf('(inside: ');
    if (start < 0) return null;
    final end = threatName.lastIndexOf(')');
    if (end <= start + 9) return null;
    return threatName.substring(start + 9, end);
  }

  static DetectionMethod _parseDetectionMethod(String? value) => switch (value) { 'signature' => DetectionMethod.signature, 'yara' => DetectionMethod.yara, 'heuristic' => DetectionMethod.heuristic, 'archive_scan' => DetectionMethod.archiveScan, _ => DetectionMethod.clean };
}
