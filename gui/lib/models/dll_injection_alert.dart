class DllInjectionAlert {
  final String processName;
  final int pid;
  final String dllPath;
  final String reason;
  final int score;
  final String detectedAt;

  const DllInjectionAlert({required this.processName, required this.pid, required this.dllPath, required this.reason, required this.score, required this.detectedAt});

  factory DllInjectionAlert.fromJson(Map<String, dynamic> json) {
    return DllInjectionAlert(
      processName: json['process_name'] as String? ?? '',
      pid: json['pid'] as int? ?? 0,
      dllPath: json['dll_path'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      detectedAt: json['detected_at'] as String? ?? '',
    );
  }
}
