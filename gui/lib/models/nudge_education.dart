
import 'nudge.dart';

class NudgeEducation {
  final String titleKey;
  final String tipKey;
  final List<String> checklistKeys;
  final List<String> actionKeys;

  const NudgeEducation({required this.titleKey, required this.tipKey, required this.checklistKeys, required this.actionKeys});

  static const Map<NudgeCategory, NudgeEducation> _data = {
    NudgeCategory.downloadedExe: NudgeEducation(titleKey: 'nudgeDownloadedExeTitle', tipKey: 'nudgeDownloadedExeTip', checklistKeys: ['nudgeDownloadedExeCheck1', 'nudgeDownloadedExeCheck2', 'nudgeDownloadedExeCheck3'], actionKeys: ['nudgeDownloadedExeAction1', 'nudgeDownloadedExeAction2']),
    NudgeCategory.macroDocument: NudgeEducation(titleKey: 'nudgeMacroDocumentTitle', tipKey: 'nudgeMacroDocumentTip', checklistKeys: ['nudgeMacroDocumentCheck1', 'nudgeMacroDocumentCheck2', 'nudgeMacroDocumentCheck3'], actionKeys: ['nudgeMacroDocumentAction1', 'nudgeMacroDocumentAction2']),
    NudgeCategory.suspiciousScript: NudgeEducation(titleKey: 'nudgeSuspiciousScriptTitle', tipKey: 'nudgeSuspiciousScriptTip', checklistKeys: ['nudgeSuspiciousScriptCheck1', 'nudgeSuspiciousScriptCheck2', 'nudgeSuspiciousScriptCheck3'], actionKeys: ['nudgeSuspiciousScriptAction1', 'nudgeSuspiciousScriptAction2']),
    NudgeCategory.usbDevice: NudgeEducation(titleKey: 'nudgeUsbDeviceTitle', tipKey: 'nudgeUsbDeviceTip', checklistKeys: ['nudgeUsbDeviceCheck1', 'nudgeUsbDeviceCheck2', 'nudgeUsbDeviceCheck3'], actionKeys: ['nudgeUsbDeviceAction1', 'nudgeUsbDeviceAction2']),
    NudgeCategory.downloadedContainer: NudgeEducation(titleKey: 'nudgeDownloadedContainerTitle', tipKey: 'nudgeDownloadedContainerTip', checklistKeys: ['nudgeDownloadedContainerCheck1', 'nudgeDownloadedContainerCheck2', 'nudgeDownloadedContainerCheck3'], actionKeys: ['nudgeDownloadedContainerAction1', 'nudgeDownloadedContainerAction2']),
  };

  static NudgeEducation of(NudgeCategory cat) => _data[cat] ?? _data[NudgeCategory.downloadedExe]!;
}
