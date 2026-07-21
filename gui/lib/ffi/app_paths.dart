import 'dart:io';
import 'package:path/path.dart' as p;

class AppPaths {
  AppPaths._();

  static final String _exeDir = p.dirname(Platform.resolvedExecutable);
  static final String _projectRoot = _resolveProjectRoot();

  static String get dllPath {
    final beside = p.join(_exeDir, 'mentoring_protector_core.dll');
    if (File(beside).existsSync()) return beside;
    final root = p.join(_projectRoot, 'mentoring_protector_core.dll');
    if (File(root).existsSync()) return root;
    return 'mentoring_protector_core.dll';
  }

  static String get helperExePath => p.join(_exeDir, 'mp_helper.exe');
  static String get extensionChromeDir => p.join(_projectRoot, 'extension', 'chrome');
  static String get projectRoot => _projectRoot;
  static String get dataDir => p.join(_projectRoot, 'data');
  static String get phishingDomainsPath => p.join(dataDir, 'phishing_domains.txt');
  static String get safeDomainsPath => p.join(dataDir, 'safe_domains.txt');
  static String get signaturesPath => p.join(dataDir, 'signatures.msdb');
  static String get heuristicRulesPath => p.join(dataDir, 'heuristic_rules.json');
  static String get threatDatabasePath => p.join(dataDir, 'threat_database.json');

  static String _resolveProjectRoot() {
    var dir = Directory.current;
    for (int i = 0; i < 6; i++) {
      if (Directory(p.join(dir.path, 'data')).existsSync()) return dir.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    dir = Directory(_exeDir);
    for (int i = 0; i < 10; i++) {
      if (Directory(p.join(dir.path, 'data')).existsSync()) return dir.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
    return p.dirname(p.dirname(_exeDir));
  }
}