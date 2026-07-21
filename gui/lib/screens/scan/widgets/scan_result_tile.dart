import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/scan_result.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';

class ScanResultTile extends StatelessWidget {
  final ScanResult result;

  final VoidCallback? onThreatTap;

  const ScanResultTile({
    super.key,
    required this.result,
    this.onThreatTap,
  });

  @override
  Widget build(BuildContext context) {
    return result.isInfected
        ? _ThreatTile(result: result, onTap: onThreatTap)
        : _CleanTile(result: result);
  }
}

class _CleanTile extends StatelessWidget {
  final ScanResult result;
  const _CleanTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colors.success,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _shortName(result.filePath),
              style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _shortName(String path) =>
      path.split(RegExp(r'[/\\]')).last;
}

class _ThreatTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback? onTap;
  const _ThreatTile({required this.result, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    final dangerColor = _dangerColor(result.dangerLevel, colors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: dangerColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dangerColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: dangerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: dangerColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _shortName(result.filePath),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.threatInfo.displayName.isNotEmpty
                        ? result.threatInfo.displayName
                        : result.threatName,
                    style: AppTextStyles.caption.copyWith(
                      color: dangerColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            _DangerBadge(level: result.dangerLevel),
            const SizedBox(width: 8),

            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: colors.textHint,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _shortName(String path) =>
      path.split(RegExp(r'[/\\]')).last;

  Color _dangerColor(int level, AdaptiveColors colors) =>
      SeverityLevel.fromDangerLevel(level).adaptiveColor(colors);
}

class _DangerBadge extends StatelessWidget {
  final int level;
  const _DangerBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final state    = context.read<AppStateProvider>();
    final colors   = state.colors;
    final severity = SeverityLevel.fromDangerLevel(level);
    final c        = severity.adaptiveColor(colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            severity.labelOf(state.strings),
            style: TextStyle(
              fontSize: AppTextStyles.sizeTiny,
              fontWeight: FontWeight.w800,
              color: c,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$level/10',
            style: TextStyle(
              fontSize: AppTextStyles.sizeTiny,
              fontWeight: FontWeight.w600,
              color: c.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

