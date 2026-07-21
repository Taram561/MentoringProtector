
enum ProcessDetectionMethod { signature, heuristic, unknown }

class ProcessAlert {
  final int pid;
  final String processName;
  final String exePath;
  final String fileHash;
  final int suspicionScore;
  final String verdict;
  final String threatName;
  final int dangerLevel;
  final ProcessDetectionMethod detectionMethod;
  final String detectedAt;
  final bool isBlocked;
  final List<String> triggeredRules;

  const ProcessAlert({required this.pid, required this.processName, required this.exePath, required this.fileHash, required this.suspicionScore, required this.verdict, required this.threatName, required this.dangerLevel, required this.detectionMethod, required this.detectedAt, required this.isBlocked, required this.triggeredRules});

  factory ProcessAlert.fromJson(Map<String, dynamic> json) {
    return ProcessAlert(
      pid: json['pid'] as int? ?? 0,
      processName: json['process_name'] as String? ?? '',
      exePath: json['exe_path'] as String? ?? '',
      fileHash: json['file_hash'] as String? ?? '',
      suspicionScore: json['score'] as int? ?? 0,
      verdict: json['verdict'] as String? ?? 'clean',
      threatName: json['threat_name'] as String? ?? '',
      dangerLevel: json['danger_level'] as int? ?? 0,
      detectionMethod: _parseMethod(json['method'] as String?),
      detectedAt: json['detected_at'] as String? ?? '',
      isBlocked: json['is_blocked'] as bool? ?? false,
      triggeredRules: (json['rules'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  bool get isDangerous => verdict == 'malicious' || verdict == 'likely_malicious';
  bool get isSuspicious => verdict == 'suspicious';

  static ProcessDetectionMethod _parseMethod(String? v) => switch (v) { 'signature' => ProcessDetectionMethod.signature, 'heuristic' => ProcessDetectionMethod.heuristic, _ => ProcessDetectionMethod.unknown };
}
