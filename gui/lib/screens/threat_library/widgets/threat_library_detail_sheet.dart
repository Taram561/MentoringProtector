import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../models/threat_info.dart';
import '../../../l10n/app_localizations.g.dart';

class ThreatLibraryDetailSheet extends StatelessWidget {
  final ThreatInfo info;

  const ThreatLibraryDetailSheet({super.key, required this.info});

  static Future<void> show(BuildContext context, ThreatInfo info) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => ThreatLibraryDetailSheet(info: info),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppStateProvider>();
    final colors = state.colors;
    final l10n = state.strings;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Spacing.l, Spacing.l, Spacing.l, Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Spacing.m),
            _ThreatLibraryHeader(info: info, colors: colors, l10n: l10n),
            const SizedBox(height: Spacing.m),
            if (info.descriptionShort.isNotEmpty) ...[
              SelectableText(
                info.descriptionShort,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  height: 1.5,
                  color: colors.textSecondary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: Spacing.m),
            ],
            const Divider(),
            const SizedBox(height: Spacing.s),
            if (info.whatItDoes.isNotEmpty)
              _EducationalSection(
                icon: Icons.bug_report_outlined,
                title: l10n.threatWhatItDoesTitle,
                content: info.whatItDoes,
                color: _dangerColor(info.dangerLevel, colors),
                initiallyExpanded: true,
              ),
            if (info.descriptionFull.isNotEmpty)
              _EducationalSection(
                icon: Icons.info_outline,
                title: l10n.threatDescriptionTitle,
                content: info.descriptionFull,
                color: colors.primary,
              ),
            if (info.howItSpreads.isNotEmpty)
              _EducationalSection(
                icon: Icons.share_outlined,
                title: l10n.threatInfectionVectorsTitle,
                content: info.howItSpreads,
                color: colors.warning,
              ),
            if (info.removalSteps.isNotEmpty)
              _EducationalSection(
                icon: Icons.healing_outlined,
                title: l10n.threatRemediationTitle,
                content: info.removalSteps.asMap().entries
                    .map((e) => '${e.key + 1}. ${e.value}')
                    .join('\n'),
                color: colors.success,
              ),
            if (info.preventionTips.isNotEmpty)
              _EducationalSection(
                icon: Icons.shield_outlined,
                title: l10n.threatPreventionTitle,
                content: info.preventionTips.map((t) => '• $t').join('\n'),
                color: colors.primary,
              ),
            const SizedBox(height: Spacing.s),
          ],
        ),
      ),
    );
  }

  static Color _dangerColor(int level, AdaptiveColors colors) {
    if (level >= 7) return colors.danger;
    if (level >= 4) return colors.warning;
    return colors.success;
  }
}

class _ThreatLibraryHeader extends StatelessWidget {
  final ThreatInfo info;
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _ThreatLibraryHeader({
    required this.info,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = ThreatLibraryDetailSheet._dangerColor(info.dangerLevel, colors);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: dangerColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.bug_report, color: dangerColor, size: 24),
        ),
        const SizedBox(width: Spacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.displayName.isNotEmpty ? info.displayName : info.name,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSubtitle,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: Spacing.s,
                runSpacing: 4,
                children: [
                  _SmallBadge(label: _typeLabel(info.type, l10n), color: colors.primary),
                  _SmallBadge(label: '${info.dangerLevel}/10', color: dangerColor),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: colors.textHint, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          splashRadius: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  String _typeLabel(String type, AppLocalizations l) {
    switch (type.toLowerCase()) {
      case 'trojan': return l.threatTypeTrojan;
      case 'spyware': return l.threatTypeSpyware;
      case 'phishing': return l.threatTypePhishing;
      case 'ransomware': return l.threatTypeRansomware;
      case 'worm': return l.threatTypeWorm;
      case 'adware': return l.threatTypeAdware;
      case 'exploit': return l.threatTypeExploit;
      case 'pup': return l.threatTypePup;
      case 'backdoor': return l.threatTypeBackdoor;
      case 'rootkit': return l.threatTypeRootkit;
      case 'test': return l.threatTypeTest;
      default: return type;
    }
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTextStyles.sizeTiny,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
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

