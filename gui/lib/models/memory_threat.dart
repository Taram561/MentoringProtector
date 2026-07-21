class MemoryThreat {
  final String processName;
  final String threatName;
  final int pid;
  final int matchesCount;
  final String exePath;
  final int memoryScanned;
  final int regionsScanned;
  final List<String> matchedSignatures;
  final int dangerLevel;

  const MemoryThreat({required this.processName, required this.threatName, required this.pid, required this.matchesCount, required this.exePath, required this.memoryScanned, required this.regionsScanned, required this.matchedSignatures, required this.dangerLevel});

  factory MemoryThreat.fromJson(Map<String, dynamic> json) {
    final rawSigs = json['matched_signatures'] as List<dynamic>? ?? [];
    return MemoryThreat(
      processName: json['process_name'] as String? ?? '',
      threatName: json['threat_name'] as String? ?? '',
      pid: json['pid'] as int? ?? 0,
      matchesCount: json['matches_count'] as int? ?? 0,
      exePath: json['exe_path'] as String? ?? '',
      memoryScanned: json['memory_scanned'] as int? ?? 0,
      regionsScanned: json['regions_scanned'] as int? ?? 0,
      matchedSignatures: rawSigs.map((s) => s.toString()).toList(),
      dangerLevel: json['danger_level'] as int? ?? 7,
    );
  }
}
