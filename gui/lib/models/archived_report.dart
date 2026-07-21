
import 'scan_result.dart';
import 'sandbox_report.dart';

enum ArchivedReportType { scan, sandbox }

class ArchivedReport {
  final String id;
  final ArchivedReportType type;
  final DateTime timestamp;
  final String filePath;
  final String fileName;
  final int dangerLevel;
  final String threatName;
  final String detectionMethod;
  final Map<String, dynamic>? scanExtras;
  final Map<String, dynamic>? sandboxData;

  const ArchivedReport({required this.id, required this.type, required this.timestamp, required this.filePath, required this.fileName, required this.dangerLevel, required this.threatName, required this.detectionMethod, this.scanExtras, this.sandboxData});

  factory ArchivedReport.fromScanResult(ScanResult r) {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${r.fileHash.isNotEmpty ? r.fileHash.substring(0, r.fileHash.length.clamp(0, 8)) : "x"}';
    return ArchivedReport(id: id, type: ArchivedReportType.scan, timestamp: DateTime.now(), filePath: r.filePath, fileName: _basename(r.filePath), dangerLevel: r.dangerLevel, threatName: r.threatName, detectionMethod: r.detectionMethod.name, scanExtras: { 'is_infected': r.isInfected, 'file_hash': r.fileHash, 'threat_type': r.threatType, 'engines_triggered': r.enginesTriggered });
  }

  factory ArchivedReport.fromSandboxRun(ScanResult r, SandboxReport sr) {
    final id = '${DateTime.now().microsecondsSinceEpoch}-sandbox';
    return ArchivedReport(id: id, type: ArchivedReportType.sandbox, timestamp: DateTime.now(), filePath: r.filePath, fileName: _basename(r.filePath), dangerLevel: r.dangerLevel, threatName: r.threatName, detectionMethod: r.detectionMethod.name, sandboxData: { 'completed': sr.completed, 'duration': sr.durationSeconds, 'risk_score': sr.riskScore, 'timed_out': sr.timedOut, 'risk_indicators': sr.riskIndicators, 'events': sr.events.map((e) => { 'type': e.type, 'target': e.target, 'detail': e.detail, 'timestamp': e.timestamp }).toList() });
  }

  Map<String, dynamic> toJson() => { 'id': id, 'type': type.name, 'timestamp': timestamp.toIso8601String(), 'file_path': filePath, 'file_name': fileName, 'danger_level': dangerLevel, 'threat_name': threatName, 'detection_method': detectionMethod, if (scanExtras != null) 'scan_extras': scanExtras, if (sandboxData != null) 'sandbox_data': sandboxData };

  factory ArchivedReport.fromJson(Map<String, dynamic> j) => ArchivedReport(id: j['id'] as String? ?? '', type: (j['type'] as String?) == 'sandbox' ? ArchivedReportType.sandbox : ArchivedReportType.scan, timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(), filePath: j['file_path'] as String? ?? '', fileName: j['file_name'] as String? ?? '', dangerLevel: (j['danger_level'] as num?)?.toInt() ?? 0, threatName: j['threat_name'] as String? ?? '', detectionMethod: j['detection_method'] as String? ?? 'clean', scanExtras: j['scan_extras'] as Map<String, dynamic>?, sandboxData: j['sandbox_data'] as Map<String, dynamic>?);

  static String _basename(String path) {
    final i = path.lastIndexOf(RegExp(r'[\\/]'));
    return i >= 0 ? path.substring(i + 1) : path;
  }
}
