import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/snack.dart';
import '../../../theme/spacing.dart';
import '../../../models/scan_result.dart';
import '../../../models/heuristic_result.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../services/threat_education_service.dart';

class ThreatDetailSheet extends StatelessWidget {
  final ScanResult result;
  final AppLocalizations l10n;
  final VoidCallback? onQuarantine;
  final VoidCallback? onDelete;
  final VoidCallback? onIgnore;
  final VoidCallback? onSandbox;
  final VoidCallback? onWhitelist;
  final VoidCallback? onLearn;

  const ThreatDetailSheet({
    super.key,
    required this.result,
    required this.l10n,
    this.onQuarantine,
    this.onDelete,
    this.onIgnore,
    this.onSandbox,
    this.onWhitelist,
    this.onLearn,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final hr = result.heuristic;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _ThreatHeader(result: result, l10n: l10n),
            const SizedBox(height: 12),

            _FilePathCard(filePath: result.filePath, l10n: l10n),
            const SizedBox(height: 12),

            _DetectionMethodBadge(result: result, l10n: l10n),
            const SizedBox(height: 12),

            if (result.detectionMethod == DetectionMethod.archiveScan) ...[
              _ArchiveThreatSection(result: result, l10n: l10n),
              const SizedBox(height: 12),
            ],

            if (result.threatInfo.descriptionShort.isNotEmpty) ...[
              SelectableText(
                result.threatInfo.descriptionShort,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  color: colors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (hr.analyzed) ...[
              _SuspicionScoreBar(score: hr.suspicionScore, verdict: hr.verdict, l10n: l10n),
              const SizedBox(height: 12),

              _FilePropertiesRow(hr: hr, l10n: l10n),
              const SizedBox(height: 12),
            ],

            if (hr.yaraMatches.isNotEmpty) ...[
              _ExpandableSection(
                icon: Icons.science,
                title: l10n.yaraRules,
                count: hr.yaraMatches.length,
                color: colors.accentPurple,
                children: hr.yaraMatches.map((m) =>
                  _YaraMatchTile(match: m, l10n: l10n),
                ).toList(),
              ),
              const SizedBox(height: 8),
            ],

            ..._buildEducationalSections(result, l10n, colors),

            if (hr.analyzed) ...[
              if (hr.suspiciousImports.isNotEmpty)
                _ExpandableSection(
                  icon: Icons.api,
                  title: l10n.threatSuspiciousImports,
                  count: hr.suspiciousImports.length,
                  color: _scoreColor(hr.suspicionScore, colors),
                  children: hr.suspiciousImports.map((name) =>
                    _ImportChip(name: name),
                  ).toList(),
                ),

              if (hr.suspiciousStrings.isNotEmpty)
                _ExpandableSection(
                  icon: Icons.text_snippet_outlined,
                  title: l10n.threatSuspiciousStrings,
                  count: hr.suspiciousStrings.length,
                  color: _scoreColor(hr.suspicionScore, colors),
                  children: hr.suspiciousStrings.map((s) =>
                    _StringChip(value: s),
                  ).toList(),
                ),

              if (hr.triggeredRules.isNotEmpty)
                _ExpandableSection(
                  icon: Icons.rule,
                  title: l10n.scanTriggeredRules,
                  count: hr.triggeredRules.length,
                  color: _scoreColor(hr.suspicionScore, colors),
                  children: hr.triggeredRules.map((r) =>
                    _RuleTile(description: r),
                  ).toList(),
                ),

              const SizedBox(height: 8),
            ],

            const Divider(height: 24),
            _ActionButtons(
              onQuarantine: onQuarantine,
              onDelete: onDelete,
              onIgnore: onIgnore,
              onSandbox: onSandbox,
              onWhitelist: onWhitelist,
              onLearn: onLearn,
              l10n: l10n,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  static Color _scoreColor(int score, AdaptiveColors colors) {
    if (score >= 80) return colors.danger;
    if (score >= 50) return colors.warning;
    return colors.success;
  }

  static List<Widget> _buildEducationalSections(
      ScanResult result, AppLocalizations l10n, AdaptiveColors colors) {
    final edu = ThreatEducationService.instance.lookup(
      threatInfo: result.threatInfo,
      threatName: result.threatName,
      threatType: result.threatType,
    );

    final widgets = <Widget>[];

    if (edu.info.whatItDoes.isNotEmpty && !edu.isCategoryLevel) {
      widgets.add(_EducationalSection(
        icon: Icons.pest_control,
        title: l10n.threatWhatItDoesTitle,
        content: edu.info.whatItDoes,
        color: colors.accentPurple,
        initiallyExpanded: true,
      ));
    }

    if (edu.isSignatureLevel && edu.info.descriptionFull.isNotEmpty) {
      widgets.add(_EducationalSection(
        icon: Icons.info_outline,
        title: l10n.threatDescriptionTitle,
        content: edu.info.descriptionFull,
        color: colors.textSecondary,
      ));
    }

    final remediationText = edu.hasContent
        ? edu.info.removalSteps.asMap().entries
            .map((e) => '${e.key + 1}. ${e.value}')
            .join('\n')
        : _categoryRemediationText(result.threatType, l10n);
    widgets.add(_EducationalSection(
      icon: Icons.healing,
      title: l10n.threatRemediationTitle,
      content: remediationText,
      color: colors.primary,
    ));

    final vectorsText = edu.info.howItSpreads.isNotEmpty
        ? edu.info.howItSpreads
        : _categoryVectorText(result.threatType, l10n);
    widgets.add(_EducationalSection(
      icon: Icons.route,
      title: l10n.threatInfectionVectorsTitle,
      content: vectorsText,
      color: colors.warning,
    ));

    final preventionText = edu.info.preventionTips.isNotEmpty
        ? edu.info.preventionTips.map((t) => '• $t').join('\n')
        : _categoryPreventionText(result.threatType, l10n);
    widgets.add(_EducationalSection(
      icon: Icons.shield_outlined,
      title: l10n.threatPreventionTitle,
      content: preventionText,
      color: colors.success,
    ));

    if (!edu.isCategoryLevel) {
      final levelColor = edu.isSignatureLevel ? colors.success : colors.warning;
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 12, color: levelColor),
            const SizedBox(width: 4),
            Text(
              edu.isSignatureLevel
                  ? l10n.threatEduLevelSignature
                  : l10n.threatEduLevelFamily,
              style: TextStyle(
                fontSize: AppTextStyles.sizeTiny,
                color: levelColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ));
    }

    return widgets;
  }


  static String _threatCategory(String threatType) {
    final lower = threatType.toLowerCase();
    if (lower.contains('trojan') || lower.contains('backdoor')) return 'trojan';
    if (lower.contains('adware')) return 'adware';
    if (lower.contains('pup') || lower.contains('pua') || lower.contains('unwanted')) return 'pup';
    if (lower.contains('worm')) return 'worm';
    if (lower.contains('ransom')) return 'ransom';
    return 'generic';
  }

  static String _categoryRemediationText(String t, AppLocalizations l10n) => switch (_threatCategory(t)) { 'trojan' => l10n.threatRemTrojan, 'adware' => l10n.threatRemAdware, 'pup' => l10n.threatRemPup, 'worm' => l10n.threatRemWorm, 'ransom' => l10n.threatRemRansom, _ => l10n.threatRemGeneric };

  static String _categoryVectorText(String t, AppLocalizations l10n) => switch (_threatCategory(t)) { 'trojan' => l10n.threatVecTrojan, 'adware' => l10n.threatVecAdware, 'pup' => l10n.threatVecPup, 'worm' => l10n.threatVecWorm, 'ransom' => l10n.threatVecRansom, _ => l10n.threatVecGeneric };

  static String _categoryPreventionText(String t, AppLocalizations l10n) => switch (_threatCategory(t)) { 'trojan' => l10n.threatPrevTrojan, 'adware' => l10n.threatPrevAdware, 'pup' => l10n.threatPrevPup, 'worm' => l10n.threatPrevWorm, 'ransom' => l10n.threatPrevRansom, _ => l10n.threatPrevGeneric };
}


class _ThreatHeader extends StatelessWidget {
  final ScanResult result;
  final AppLocalizations l10n;
  const _ThreatHeader({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final severity = result.severity;

    return Row(
      children: [
        Icon(severity.icon, color: severity.adaptiveColor(colors), size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            result.threatInfo.displayName.isNotEmpty
                ? result.threatInfo.displayName
                : result.threatName,
            style: TextStyle(
              fontSize: AppTextStyles.sizeMedium,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: Spacing.xs),
          decoration: BoxDecoration(
            color: severity.adaptiveColor(colors).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(severity.icon, size: 13, color: severity.adaptiveColor(colors)),
              const SizedBox(width: 4),
              Text(
                severity.labelOf(l10n),
                style: TextStyle(
                  fontSize: AppTextStyles.sizeXSmall,
                  fontWeight: FontWeight.w800,
                  color: severity.adaptiveColor(colors),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${result.dangerLevel}/10',
                style: TextStyle(
                  fontSize: AppTextStyles.sizeXSmall,
                  fontWeight: FontWeight.w600,
                  color: severity.adaptiveColor(colors).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilePathCard extends StatelessWidget {
  final String filePath;
  final AppLocalizations l10n;
  const _FilePathCard({required this.filePath, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.cardBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              filePath,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: AppTextStyles.sizeXSmall,
                color: colors.textSecondary,
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              Snack.info(context, l10n.copiedToClipboard,
                  duration: const Duration(seconds: 1));
            },
            icon: const Icon(Icons.copy, size: 16),
            tooltip: l10n.copyPath,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            style: IconButton.styleFrom(
              foregroundColor: colors.primary,
            ),
          ),
          IconButton(
            onPressed: () => _openFileLocation(filePath),
            icon: const Icon(Icons.folder_open, size: 18),
            tooltip: l10n.threatOpenFileLocation,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            style: IconButton.styleFrom(
              foregroundColor: colors.primary,
            ),
          ),
        ],
      ),
    );
  }

  static void _openFileLocation(String path) {
    final normalized = path.replaceAll('/', '\\');
    if (!RegExp(r'^[A-Za-z]:\\[^<>"|?*]+$').hasMatch(normalized)) return;

    Process.run('explorer.exe', ['/select,', normalized]);
  }
}

class _DetectionMethodBadge extends StatelessWidget {
  final ScanResult result;
  final AppLocalizations l10n;
  const _DetectionMethodBadge({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final (icon, label, color) = switch (result.detectionMethod) {
      DetectionMethod.signature => (
        Icons.fingerprint,
        l10n.scanMethodSignature,
        colors.primary,
      ),
      DetectionMethod.yara => (
        Icons.science,
        l10n.yaraRules,
        colors.accentPurple,
      ),
      DetectionMethod.heuristic => (
        Icons.psychology,
        l10n.scanMethodHeuristic,
        colors.warning,
      ),
      DetectionMethod.archiveScan => (
        Icons.folder_zip_outlined,
        l10n.detectionMethodArchive,
        colors.severityHigh,
      ),
      DetectionMethod.clean => (
        Icons.check_circle,
        l10n.threatVerdictClean,
        colors.success,
      ),
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTextStyles.sizeSmall,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ArchiveThreatSection extends StatelessWidget {
  final ScanResult result;
  final AppLocalizations l10n;
  const _ArchiveThreatSection({required this.result, required this.l10n});

  String? _extractInnerPath() {
    final name = result.threatName;
    final start = name.lastIndexOf('(inside: ');
    if (start < 0) return null;
    final end = name.lastIndexOf(')');
    if (end <= start) return null;
    return name.substring(start + 9, end);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final innerPath = _extractInnerPath();

    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: colors.severityHigh.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.severityHigh.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_zip_outlined, size: 16, color: colors.severityHigh),
              const SizedBox(width: 6),
              Text(
                l10n.archiveThreatFound,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontWeight: FontWeight.w600,
                  color: colors.severityHigh,
                ),
              ),
            ],
          ),
          if (innerPath != null) ...[
            const SizedBox(height: 6),
            SelectableText(
              innerPath,
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                fontFamily: 'monospace',
                color: colors.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.archiveTeachableMoment,
            style: TextStyle(
              fontSize: AppTextStyles.sizeSmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuspicionScoreBar extends StatelessWidget {
  final int score;
  final String verdict;
  final AppLocalizations l10n;
  const _SuspicionScoreBar({required this.score, required this.verdict, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final color = ThreatDetailSheet._scoreColor(score, colors);
    final clampedFraction = (score / 100).clamp(0.0, 1.0);

    final verdictText = switch (verdict) {
      'clean' => l10n.threatVerdictClean,
      'suspicious' => l10n.threatVerdictSuspicious,
      'likely_malicious' => l10n.threatVerdictLikelyMalicious,
      _ => verdict,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.threatSuspicionLevel,
              style: TextStyle(
                fontSize: AppTextStyles.sizeDefault,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            Text(
              '$score/100 - $verdictText',
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clampedFraction,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _FilePropertiesRow extends StatelessWidget {
  final dynamic hr;
  final AppLocalizations l10n;
  const _FilePropertiesRow({required this.hr, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            if (hr.isPeFile) _PropertyChip(
              icon: Icons.memory, label: l10n.threatPeFile, positive: true),
            if (hr.isPacked) _PropertyChip(
              icon: Icons.compress, label: l10n.scanIsPacked, positive: false),
            if (hr.hasSignature && !hr.signature.isRevoked)
              _PropertyChip(
                icon: Icons.verified, label: l10n.threatSigned, positive: true)
            else if (hr.hasSignature && hr.signature.isRevoked)
              _PropertyChip(
                icon: Icons.gpp_bad, label: l10n.threatCertRevoked, positive: false)
            else if (hr.isPeFile)
              _PropertyChip(
                icon: Icons.gpp_bad_outlined, label: l10n.threatUnsigned, positive: false),
            _PropertyChip(
              icon: Icons.bar_chart,
              label: l10n.threatEntropyValue(hr.entropy.toStringAsFixed(1)),
              positive: hr.entropy < 6.8,
            ),
          ],
        ),
        if (hr.signature.hasInfo) ...[
          const SizedBox(height: 8),
          _SignatureDetailsCard(signature: hr.signature, l10n: l10n),
        ],
      ],
    );
  }
}

class _SignatureDetailsCard extends StatelessWidget {
  final dynamic signature;
  final AppLocalizations l10n;

  const _SignatureDetailsCard({required this.signature, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final isRevoked = signature.isRevoked as bool;
    final borderColor = isRevoked ? colors.danger : colors.success;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: borderColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isRevoked ? Icons.warning_amber_rounded : Icons.shield_outlined,
                size: 16,
                color: borderColor,
              ),
              const SizedBox(width: 6),
              Text(
                isRevoked ? l10n.threatSigRevokedTitle : l10n.threatDigitalSignatureTitle,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontWeight: FontWeight.w700,
                  color: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _sigRow(l10n.threatSigner, signature.signerName as String, colors),
          if ((signature.issuer as String).isNotEmpty)
            _sigRow(l10n.threatIssuer, signature.issuer as String, colors),
          if ((signature.expiryDate as String).isNotEmpty)
            _sigRow(l10n.threatValidUntil, signature.expiryDate as String, colors),
          if (isRevoked)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Text(
                l10n.threatRevokedWarning,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeXSmall,
                  color: colors.danger.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sigRow(String label, String value, AdaptiveColors colors) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textHint),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTextStyles.sizeXSmall,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool positive;
  const _PropertyChip({
    required this.icon, required this.label, required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final color = positive ? colors.success : colors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: AppTextStyles.sizeXSmall, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final List<Widget> children;

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.children,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s),
            child: Row(
              children: [
                Icon(widget.icon, size: 18, color: widget.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeDefault,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeXSmall,
                      fontWeight: FontWeight.w700,
                      color: widget.color,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: context.read<AppStateProvider>().colors.textHint,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.children,
            ),
          ),
      ],
    );
  }
}

class _ImportChip extends StatelessWidget {
  final String name;
  const _ImportChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.warning.withValues(alpha: 0.25)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: AppTextStyles.sizeXSmall,
          fontWeight: FontWeight.w600,
          color: colors.warning,
        ),
      ),
    );
  }
}

class _StringChip extends StatelessWidget {
  final String value;
  const _StringChip({required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.danger.withValues(alpha: 0.25)),
      ),
      child: Text(
        '"$value"',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: AppTextStyles.sizeXSmall,
          fontWeight: FontWeight.w600,
          color: colors.danger,
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final String description;
  const _RuleTile({required this.description});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: Spacing.xs),
              child: Icon(Icons.circle, size: 6,
                  color: context.read<AppStateProvider>().colors.warning),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  color: context.read<AppStateProvider>().colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YaraMatchTile extends StatelessWidget {
  final YaraMatchResult match;
  final AppLocalizations l10n;
  const _YaraMatchTile({required this.match, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.accentPurple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.accentPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule, size: 14, color: colors.accentPurple),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  match.ruleName,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: AppTextStyles.sizeSmall,
                    fontWeight: FontWeight.w700,
                    color: colors.accentPurple,
                  ),
                ),
              ),
              if (match.metaSeverity.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _severityColor(match.metaSeverity, colors)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match.metaSeverity.toUpperCase(),
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeMicro,
                      fontWeight: FontWeight.w800,
                      color: _severityColor(match.metaSeverity, colors),
                    ),
                  ),
                ),
            ],
          ),
          if (match.metaDesc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              match.metaDesc,
              style: TextStyle(
                fontSize: AppTextStyles.sizeXSmall,
                color: colors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ],
          if (match.metaAuthor.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              l10n.threatAuthorPrefix(match.metaAuthor),
              style: TextStyle(fontSize: AppTextStyles.sizeTiny, color: colors.textHint),
            ),
          ],
          if (match.tags.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: match.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeTiny,
                    fontWeight: FontWeight.w600,
                    color: colors.accentPurple,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  static Color _severityColor(String severity, AdaptiveColors colors) {
    final lower = severity.toLowerCase();
    if (lower == 'critical' || lower == 'high') return colors.danger;
    if (lower == 'medium' || lower == 'moderate') return colors.warning;
    return colors.success;
  }
}

class _EducationalSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;
  final bool initiallyExpanded;

  const _EducationalSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
    this.initiallyExpanded = false,
  });

  @override
  State<_EducationalSection> createState() => _EducationalSectionState();
}

class _EducationalSectionState extends State<_EducationalSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.s),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(widget.icon, size: 16, color: widget.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeDefault,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: colors.textHint,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 38, bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.color.withValues(alpha: 0.15)),
            ),
            child: SelectableText(
              widget.content,
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback? onQuarantine;
  final VoidCallback? onDelete;
  final VoidCallback? onIgnore;
  final VoidCallback? onSandbox;
  final VoidCallback? onWhitelist;
  final VoidCallback? onLearn;
  final AppLocalizations l10n;

  const _ActionButtons({
    this.onQuarantine, this.onDelete, this.onIgnore, this.onSandbox,
    this.onWhitelist, this.onLearn,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Column(
      children: [
        if (onQuarantine != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onQuarantine,
              icon: const Icon(Icons.shield, size: 18),
              label: Text(l10n.scanQuarantine),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: Spacing.m),
              ),
            ),
          ),
        if (onSandbox != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSandbox,
              icon: Icon(Icons.science_outlined, size: 18, color: colors.accentTeal),
              label: Text(l10n.sandboxAnalyse,
                  style: TextStyle(color: colors.accentTeal)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.accentTeal.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: Spacing.m),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            if (onDelete != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_forever,
                      size: 18, color: colors.danger),
                  label: Text(l10n.scanDeleteFile,
                      style: TextStyle(color: colors.danger)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.danger),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  ),
                ),
              ),
            if (onDelete != null && onIgnore != null)
              const SizedBox(width: 8),
            if (onIgnore != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onIgnore,
                  icon: const Icon(Icons.visibility_off, size: 18),
                  label: Text(l10n.scanIgnore),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  ),
                ),
              ),
          ],
        ),
        if (onWhitelist != null || onLearn != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onWhitelist != null)
                TextButton.icon(
                  onPressed: onWhitelist,
                  icon: Icon(Icons.shield_outlined, size: 16,
                      color: colors.textSecondary),
                  label: Text(l10n.btnWhitelist,
                      style: TextStyle(color: colors.textSecondary,
                          fontSize: 12)),
                ),
              if (onWhitelist != null && onLearn != null)
                SizedBox(
                  height: 16,
                  child: VerticalDivider(color: colors.textHint, width: 16),
                ),
              if (onLearn != null)
                TextButton.icon(
                  onPressed: onLearn,
                  icon: Icon(Icons.menu_book_outlined, size: 16,
                      color: colors.textSecondary),
                  label: Text(l10n.btnLearn,
                      style: TextStyle(color: colors.textSecondary,
                          fontSize: 12)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

