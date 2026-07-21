import 'package:flutter/material.dart';
import '../../../models/threat_info.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import 'threat_library_detail_sheet.dart';
import 'package:provider/provider.dart';

class ThreatCard extends StatelessWidget {
  final ThreatInfo info;

  const ThreatCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final dangerColor = _dangerColor(info.dangerLevel, colors);

    return AppCard(
      padding: Spacing.cardPadding,
      onTap: () => ThreatLibraryDetailSheet.show(context, info),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: dangerColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.bug_report_outlined, color: dangerColor, size: 20),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        info.displayName.isNotEmpty ? info.displayName : info.name,
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeDefault,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.s),
                    _TypeBadge(type: info.type, colors: colors),
                  ],
                ),
                const SizedBox(height: 2),
                if (info.descriptionShort.isNotEmpty)
                  Text(
                    info.descriptionShort,
                    style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.s),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: dangerColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${info.dangerLevel}/10',
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeTiny,
                    fontWeight: FontWeight.w700,
                    color: dangerColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right, color: colors.textHint, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  static Color _dangerColor(int level, AdaptiveColors colors) {
    if (level >= 7) return colors.danger;
    if (level >= 4) return colors.warning;
    return colors.success;
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final AdaptiveColors colors;

  const _TypeBadge({required this.type, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: AppTextStyles.sizeMicro,
          fontWeight: FontWeight.w600,
          color: colors.primary,
        ),
      ),
    );
  }
}

