enum NudgeCategory {
  downloadedExe, macroDocument, suspiciousScript, usbDevice, downloadedContainer;
  static NudgeCategory fromString(String s) => switch (s) { 'downloaded_exe' => downloadedExe, 'macro_document' => macroDocument, 'suspicious_script' => suspiciousScript, 'usb_device' => usbDevice, 'downloaded_container' => downloadedContainer, _ => downloadedExe };
  bool get isSecurity => this == downloadedExe || this == suspiciousScript || this == downloadedContainer;
}

class Nudge {
  final NudgeCategory category;
  final String detail;
  final String context;
  final String severity;
  final String detectedAt;

  const Nudge({
    required this.category,
    required this.detail,
    this.context = '',
    this.severity = 'info',
    this.detectedAt = '',
  });

  factory Nudge.fromJson(Map<String, dynamic> j) => Nudge(
    category: NudgeCategory.fromString(j['category'] as String? ?? ''),
    detail: j['detail'] as String? ?? '',
    context: j['context'] as String? ?? '',
    severity: j['severity'] as String? ?? 'info',
    detectedAt: j['detected_at'] as String? ?? '',
  );
}
