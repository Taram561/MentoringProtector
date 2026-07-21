
import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../l10n/app_localizations.g.dart';
import '../../theme/app_theme.dart';

enum HygieneTipId {
  update,
  passwords,
  wifi,
  phishing,
  backup,
  downloads,
  twoFactor,
  usb,
  privacy,
  lock,
  extensions,
  encryption,
}

class HygieneTipData {
  final HygieneTipId id;
  final IconData icon;
  final Color Function(AdaptiveColors) color;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) description;

  final String Function(AppLocalizations)? descriptionBeginner;
  final String Function(AppLocalizations)? descriptionAdvanced;

  const HygieneTipData({
    required this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.descriptionBeginner,
    this.descriptionAdvanced,
  });

  String adaptiveDescription(AppLocalizations l10n, UserLevel level) {
    return switch (level) { UserLevel.beginner => descriptionBeginner?.call(l10n) ?? description(l10n), UserLevel.advanced => descriptionAdvanced?.call(l10n) ?? description(l10n), UserLevel.regular => description(l10n) };
  }
}

const tipRiskMapping = <HygieneTipId, List<RiskEventType>>{ HygieneTipId.phishing: [RiskEventType.webWarningIgnored], HygieneTipId.downloads: [RiskEventType.dangerousDownload], HygieneTipId.update: [RiskEventType.protectionDisabled], HygieneTipId.passwords: [], HygieneTipId.wifi: [], HygieneTipId.backup: [RiskEventType.scanThreatIgnored], HygieneTipId.twoFactor: [], HygieneTipId.usb: [], HygieneTipId.privacy: [], HygieneTipId.lock: [], HygieneTipId.extensions: [RiskEventType.webWarningIgnored], HygieneTipId.encryption: [] };

double tipPriority(HygieneTipId tip, UserProfile profile, Set<String> completedTips) {
  double score = 0;

  if (completedTips.contains(tip.name)) {
    score -= 50;
  }

  final relatedTypes = tipRiskMapping[tip] ?? [];
  if (relatedTypes.isNotEmpty) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final count = profile.events
        .where((e) => e.timestamp.isAfter(cutoff) && relatedTypes.contains(e.type))
        .length;
    score += count * 20;
  }

  if (profile.level == UserLevel.beginner) {
    const beginnerPriority = {
      HygieneTipId.phishing, HygieneTipId.passwords,
      HygieneTipId.downloads, HygieneTipId.lock,
    };
    if (beginnerPriority.contains(tip)) score += 10;
  }

  return score;
}

int computeHygieneIndex(UserProfile profile, Set<String> completedTips) {
  double index = 50;

  for (final tipId in completedTips) {
    final result = profile.quizResults[tipId];
    if (result != null) {
      if (result.isPerfect) {
        index += 3;
      } else if (result.ratio >= 0.6) {
        index += 2;
      } else {
        index += 1;
      }
    } else {
      index += 1;
    }
  }

  final cutoff = DateTime.now().subtract(const Duration(days: 30));
  final recent = profile.events.where((e) => e.timestamp.isAfter(cutoff));
  for (final e in recent) {
    if (e.type == RiskEventType.quizWrongAnswer) {
      index -= 4;
    } else if (e.type.weight > 0) {
      index -= 3;
    } else {
      index += 2;
    }
  }

  return index.round().clamp(0, 100);
}

final allTips = <HygieneTipData>[
  HygieneTipData(
    id: HygieneTipId.update, icon: Icons.update,
    color: (c) => c.primary,
    title: (l) => l.hygieneUpdateTitle, description: (l) => l.hygieneUpdateDesc,
    descriptionBeginner: (l) => l.hygieneUpdateDescBeginner,
    descriptionAdvanced: (l) => l.hygieneUpdateDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.passwords, icon: Icons.password,
    color: (c) => c.success,
    title: (l) => l.hygienePasswordTitle, description: (l) => l.hygienePasswordDesc,
    descriptionBeginner: (l) => l.hygienePasswordDescBeginner,
    descriptionAdvanced: (l) => l.hygienePasswordDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.wifi, icon: Icons.wifi_lock,
    color: (c) => c.warning,
    title: (l) => l.hygieneWifiTitle, description: (l) => l.hygieneWifiDesc,
    descriptionBeginner: (l) => l.hygieneWifiDescBeginner,
    descriptionAdvanced: (l) => l.hygieneWifiDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.phishing, icon: Icons.email_outlined,
    color: (c) => c.danger,
    title: (l) => l.hygienePhishingTitle, description: (l) => l.hygienePhishingDesc,
    descriptionBeginner: (l) => l.hygienePhishingDescBeginner,
    descriptionAdvanced: (l) => l.hygienePhishingDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.backup, icon: Icons.backup,
    color: (c) => c.primary,
    title: (l) => l.hygieneBackupTitle, description: (l) => l.hygieneBackupDesc,
    descriptionBeginner: (l) => l.hygieneBackupDescBeginner,
    descriptionAdvanced: (l) => l.hygieneBackupDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.downloads, icon: Icons.download_outlined,
    color: (c) => c.warning,
    title: (l) => l.hygieneDownloadTitle, description: (l) => l.hygieneDownloadDesc,
    descriptionBeginner: (l) => l.hygieneDownloadDescBeginner,
    descriptionAdvanced: (l) => l.hygieneDownloadDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.twoFactor, icon: Icons.phonelink_lock,
    color: (c) => c.success,
    title: (l) => l.hygiene2faTitle, description: (l) => l.hygiene2faDesc,
    descriptionBeginner: (l) => l.hygiene2faDescBeginner,
    descriptionAdvanced: (l) => l.hygiene2faDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.usb, icon: Icons.usb_outlined,
    color: (c) => c.danger,
    title: (l) => l.hygieneUsbTitle, description: (l) => l.hygieneUsbDesc,
    descriptionBeginner: (l) => l.hygieneUsbDescBeginner,
    descriptionAdvanced: (l) => l.hygieneUsbDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.privacy, icon: Icons.visibility_off_outlined,
    color: (c) => c.primary,
    title: (l) => l.hygienePrivacyTitle, description: (l) => l.hygienePrivacyDesc,
    descriptionBeginner: (l) => l.hygienePrivacyDescBeginner,
    descriptionAdvanced: (l) => l.hygienePrivacyDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.lock, icon: Icons.lock_outline,
    color: (c) => c.warning,
    title: (l) => l.hygieneLockTitle, description: (l) => l.hygieneLockDesc,
    descriptionBeginner: (l) => l.hygieneLockDescBeginner,
    descriptionAdvanced: (l) => l.hygieneLockDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.extensions, icon: Icons.extension_outlined,
    color: (c) => c.danger,
    title: (l) => l.hygieneExtensionsTitle, description: (l) => l.hygieneExtensionsDesc,
    descriptionBeginner: (l) => l.hygieneExtensionsDescBeginner,
    descriptionAdvanced: (l) => l.hygieneExtensionsDescAdvanced,
  ),
  HygieneTipData(
    id: HygieneTipId.encryption, icon: Icons.enhanced_encryption_outlined,
    color: (c) => c.success,
    title: (l) => l.hygieneEncryptionTitle, description: (l) => l.hygieneEncryptionDesc,
    descriptionBeginner: (l) => l.hygieneEncryptionDescBeginner,
    descriptionAdvanced: (l) => l.hygieneEncryptionDescAdvanced,
  ),
];

String? tipReasonText(HygieneTipId tip, UserProfile profile,
    AppLocalizations l10n) {
  final relatedTypes = tipRiskMapping[tip] ?? [];
  if (relatedTypes.isEmpty) return null;

  final cutoff = DateTime.now().subtract(const Duration(days: 30));
  final hasRelated = profile.events.any(
    (e) => e.timestamp.isAfter(cutoff) && relatedTypes.contains(e.type),
  );
  if (!hasRelated) return null;

  return switch (relatedTypes.first) { RiskEventType.webWarningIgnored => l10n.hygieneReasonWeb, RiskEventType.scanThreatIgnored => l10n.hygieneReasonScan, RiskEventType.dangerousDownload => l10n.hygieneReasonDownload, RiskEventType.protectionDisabled => l10n.hygieneReasonProtection, _ => null };
}

