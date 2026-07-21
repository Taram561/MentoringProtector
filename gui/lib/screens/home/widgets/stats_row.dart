import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../theme/app_theme.dart';

class StatCardData {
  final IconData icon;
  final String   value;
  final String   label;
  final Color    iconColor;

  const StatCardData({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });
}

class StatsRow extends StatelessWidget {
  final StatCardData left;
  final StatCardData right;

  const StatsRow({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(data: left)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(data: right)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatCardData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<AppStateProvider>().colors;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: data.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon,
                  color: data.iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(data.value,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeSubtitle,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary)),
            const SizedBox(height: 2),
            Text(data.label,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeSmall,
                    color: colors.textHint)),
          ],
        ),
    );
  }
}

