
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_profile.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import 'hygiene_sparkline.dart';

class HygieneIndexCard extends StatelessWidget {
  final int index;
  final List<HygieneSnapshot> history;
  final int completedCount;
  final int totalCount;
  final AppLocalizations l10n;

  const HygieneIndexCard({
    super.key,
    required this.index,
    required this.history,
    required this.completedCount,
    required this.totalCount,
    required this.l10n,
  });

  Color _indexColor(AdaptiveColors c) {
    if (index >= 75) return c.success;
    if (index >= 50) return c.warning;
    if (index >= 30) return c.severityHigh;
    return c.severityCritical;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final ic     = _indexColor(colors);
    final change = _computeChange();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: ic, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.hygieneIndexTitle,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeSubtitle,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: index / 100,
                          strokeWidth: 6,
                          backgroundColor: ic.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(ic),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$index',
                            style: TextStyle(
                              fontSize: AppTextStyles.sizeLarge,
                              fontWeight: FontWeight.w800,
                              color: ic,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              fontSize: AppTextStyles.sizeTiny,
                              color: colors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (change != null)
                        Row(
                          children: [
                            Icon(
                              change >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 16,
                              color: change >= 0
                                  ? colors.success
                                  : colors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              change >= 0
                                  ? l10n.hygieneIndexGrowth(change.abs())
                                  : l10n.hygieneIndexDecline(change.abs()),
                              style: TextStyle(
                                fontSize: AppTextStyles.sizeSmall,
                                fontWeight: FontWeight.w600,
                                color: change >= 0
                                    ? colors.success
                                    : colors.danger,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),

                      Text(
                        l10n.hygieneCompleted(completedCount, totalCount),
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeDefault,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (history.length >= 2) ...[
              const SizedBox(height: 16),
              Text(
                l10n.hygieneHistory,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeXSmall,
                  color: colors.textHint,
                ),
              ),
              const SizedBox(height: 4),
              HygieneSparkline(
                history: history,
                color: ic,
                height: 50,
                dotCenter: colors.surface,
              ),
            ],
          ],
        ),
      ),
    );
  }

  int? _computeChange() {
    if (history.length < 2) return null;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final oldSnapshot = history
        .where((s) => s.date.isBefore(weekAgo))
        .toList();
    if (oldSnapshot.isEmpty) return null;
    return index - oldSnapshot.last.score;
  }
}

