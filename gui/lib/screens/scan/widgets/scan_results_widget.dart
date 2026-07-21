import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/scan_result.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import 'scan_result_tile.dart';
import '../../../theme/app_theme.dart';

class ScanResultsWidget extends StatelessWidget {
  final List<ScanResult> allResults;
  final List<ScanResult> threats;
  final int filesScanned;
  final Duration? elapsed;
  final int activeEngines;
  final void Function(ScanResult)? onThreatTap;

  const ScanResultsWidget({
    super.key,
    required this.allResults,
    required this.threats,
    required this.filesScanned,
    required this.elapsed,
    required this.activeEngines,
    this.onThreatTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.scanResults,
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeSubtitle,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
                const Spacer(),
                if (threats.isNotEmpty)
                  _CountBadge(
                    icon: Icons.warning_amber_rounded,
                    label: '${threats.length}',
                    color: colors.danger,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            _SummaryHeader(
              filesScanned: filesScanned,
              threatsCount: threats.length,
              elapsed: elapsed,
              activeEngines: activeEngines,
            ),

            const SizedBox(height: 8),
            Divider(color: colors.divider),

            ...threats.map((r) => ScanResultTile(
                  result: r,
                  onThreatTap:
                      onThreatTap == null ? null : () => onThreatTap!(r),
                )),

            ...allResults
                .where((r) => !r.isInfected)
                .map((r) => ScanResultTile(result: r)),
          ],
        ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int filesScanned;
  final int threatsCount;
  final Duration? elapsed;
  final int activeEngines;

  const _SummaryHeader({
    required this.filesScanned,
    required this.threatsCount,
    required this.elapsed,
    required this.activeEngines,
  });

  String _formatElapsed(Duration d) {
    if (d.inMinutes >= 1) {
      return '${d.inMinutes}m ${d.inSeconds % 60}s';
    }
    return '${d.inSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final colors = state.colors;
    final l10n   = state.strings;
    final muted = colors.textPrimary.withValues(alpha: 0.7);

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _Stat(
          icon: Icons.description_outlined,
          value: '$filesScanned',
          tooltip: l10n.scanStatsFilesScanned,
          color: muted,
        ),
        if (elapsed != null)
          _Stat(
            icon: Icons.timer_outlined,
            value: _formatElapsed(elapsed!),
            tooltip: l10n.scanStatsElapsedTime,
            color: muted,
          ),
        _Stat(
          icon: Icons.shield_outlined,
          value: '$activeEngines',
          tooltip: l10n.scanStatsActiveEngines,
          color: muted,
        ),
        _Stat(
          icon: Icons.warning_amber_rounded,
          value: '$threatsCount',
          tooltip: l10n.scanStatsThreatsFound,
          color: threatsCount > 0 ? colors.danger : muted,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String tooltip;
  final Color color;
  const _Stat({
    required this.icon,
    required this.value,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppTextStyles.sizeDefault,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CountBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

