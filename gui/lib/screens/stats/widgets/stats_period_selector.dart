
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../theme/app_theme.dart';

class StatsPeriodSelector extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const StatsPeriodSelector({
    super.key,
    required this.selectedDays,
    required this.onChanged,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<int>(
        segments: <ButtonSegment<int>>[
          ButtonSegment<int>(value: 7, label: Text(l10n.statsPeriod7Days)),
          ButtonSegment<int>(value: 30, label: Text(l10n.statsPeriod30Days)),
          ButtonSegment<int>(value: 90, label: Text(l10n.statsPeriod90Days)),
        ],
        selected: <int>{selectedDays},
        onSelectionChanged: (set) {
          if (set.isNotEmpty) onChanged(set.first);
        },
        showSelectedIcon: false,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primary.withValues(alpha: 0.12);
            }
            return colors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.primary;
            }
            return colors.textSecondary;
          }),
          side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(WidgetState.selected)) {
              return BorderSide(color: colors.primary.withValues(alpha: 0.6));
            }
            return BorderSide(color: colors.cardBorder);
          }),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: AppTextStyles.sizeDefault, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

