class ProcessModule {
  final String name;
  final int size;

  const ProcessModule({this.name = '', this.size = 0});

  factory ProcessModule.fromJson(Map<String, dynamic> j) => ProcessModule(name: (j['name'] as String?) ?? '', size: (j['size'] as num?)?.toInt() ?? 0);
}

class ProcessAnalysis {
  final int pid;
  final String processName;
  final String exePath;
  final int parentPid;
  final String cmdline;
  final String fileHash;
  final String digitalSignature;
  final int score;
  final String verdict;
  final int dangerLevel;
  final String method;
  final List<ProcessModule> modules;

  const ProcessAnalysis({this.pid = 0, this.processName = '', this.exePath = '', this.parentPid = 0, this.cmdline = '', this.fileHash = '', this.digitalSignature = '', this.score = 0, this.verdict = '', this.dangerLevel = 0, this.method = '', this.modules = const []});

  factory ProcessAnalysis.fromJson(Map<String, dynamic> j) => ProcessAnalysis(pid: (j['pid'] as num?)?.toInt() ?? 0, processName: (j['process_name'] as String?) ?? '', exePath: (j['exe_path'] as String?) ?? '', parentPid: (j['parent_pid'] as num?)?.toInt() ?? 0, cmdline: (j['cmdline'] as String?) ?? '', fileHash: (j['file_hash'] as String?) ?? '', digitalSignature: (j['digital_signature'] as String?) ?? '', score: (j['score'] as num?)?.toInt() ?? 0, verdict: (j['verdict'] as String?) ?? '', dangerLevel: (j['danger_level'] as num?)?.toInt() ?? 0, method: (j['method'] as String?) ?? '', modules: ((j['modules'] as List?) ?? []).map((e) => ProcessModule.fromJson(e as Map<String, dynamic>)).toList());

  factory ProcessAnalysis.empty() => const ProcessAnalysis();
}
