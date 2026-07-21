
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/stats_provider.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../theme/app_theme.dart';

class StatsPreviewCard extends StatelessWidget {
  final VoidCallback onOpen;

  const StatsPreviewCard({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final colors = state.colors;
    final l10n   = state.strings;

    final stats = context.watch<StatsProvider>().threatStats;
    int last7dThreats = 0;
    if (stats != null && stats.daily.isNotEmpty) {
      final tail = stats.daily.length >= 7
          ? stats.daily.sublist(stats.daily.length - 7)
          : stats.daily;
      for (final d in tail) {
        last7dThreats += d.threats;
      }
    }

    return AppCard(
      padding: Spacing.cardPadding,
      onTap: onOpen,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.insights_outlined,
                color: colors.primary, size: 20),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.statsScreenTitle,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeDefault,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.statsScreenSubtitle,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.s),
          if (stats != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  last7dThreats.toString(),
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeSubtitle,
                    fontWeight: FontWeight.w700,
                    color: last7dThreats > 0
                        ? colors.danger
                        : colors.textPrimary,
                  ),
                ),
                Text(
                  l10n.statsPeriod7Days,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeTiny, color: colors.textHint),
                ),
              ],
            ),
            const SizedBox(width: Spacing.s),
          ],
          Icon(Icons.chevron_right, color: colors.textHint, size: 20),
        ],
      ),
    );
  }
}

