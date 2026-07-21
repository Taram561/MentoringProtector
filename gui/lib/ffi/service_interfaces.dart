import '../models/sandbox_report.dart';
import '../models/scan_result.dart';
import 'core_result.dart';

abstract interface class IExclusionService {
  Future<List<String>> getExclusions();
  Future<bool> addExclusion(String path);
  Future<bool> removeExclusion(String path);
}

abstract interface class IModuleControlService {
  void startRealtime();
  void stopRealtime();
  void startProcessMonitoring();
  void stopProcessMonitoring();
  void startWebProtection(String phishingPath, String safePath);
  void stopWebProtection();
  void startMemoryScan();
  void stopMemoryScan();
  Future<bool> reloadYaraRules();
}

abstract interface class IQuarantineService {
  Future<QuarantineOperationResult> quarantineFile({required ScanResult scanResult});
  Future<QuarantineOperationResult> restoreFile(String entryId);
  Future<QuarantineOperationResult> deleteFile(String entryId);
  Future<QuarantineList> getQuarantineList();
}

class SandboxRunResult {
  final bool success;
  final String? errorCode;
  const SandboxRunResult({required this.success, this.errorCode});
  factory SandboxRunResult.fromJson(Map<String, dynamic> m) => SandboxRunResult(success: m['success'] == true, errorCode: m['error'] as String?);
}

abstract class ISandboxService {
  Future<bool> isSupported();
  Future<SandboxRunResult> run(String filePath);
  Future<Map<String, dynamic>> getStatus();
  Future<SandboxReport> getReport();
  Future<void> cancel();
}

abstract interface class IScannerService {
  Future<ScanResult> scanFile(String filePath);
  Future<String> getFileHash(String filePath);
}

abstract interface class ISmartCacheService {
  bool get isAvailable;
  Future<bool> invalidateCache();
  Future<bool> clearCache();
}

abstract interface class IVulnService {
  Future<String?> getFixDescriptor(String vulnId);
}
