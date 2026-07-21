import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import '../scan_controller.dart';

class ScanProgressCard extends StatelessWidget {
  final ScanState     state;
  final VoidCallback? onCancel;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onReset;
  final bool          isPaused;
  final String?       driveLabel;

  const ScanProgressCard({
    super.key,
    required this.state,
    this.onCancel,
    this.onPause,
    this.onResume,
    this.onReset,
    this.isPaused = false,
    this.driveLabel,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final l10n     = appState.strings;
    final colors   = appState.colors;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(Spacing.xl),
      child: switch (state) {
          ScanIdle()     => _buildIdle(l10n, colors),
          ScanRunning()  => _buildRunning(state as ScanRunning, l10n, colors),
          ScanFinished() => _buildFinished(state as ScanFinished, l10n, colors),
          ScanError()    => _buildError(state as ScanError, colors),
        },
    );
  }

  Widget _buildIdle(AppLocalizations l10n, AdaptiveColors colors) {
    return Row(
      children: [
        Icon(Icons.info_outline, color: colors.textHint),
        const SizedBox(width: 12),
        Text(l10n.scanSelectTarget,
            style: TextStyle(
                fontSize: AppTextStyles.sizeBody,
                color: colors.textSecondary,
                height: 1.5)),
      ],
    );
  }

  Widget _buildRunning(ScanRunning s, AppLocalizations l10n,
      AdaptiveColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.scanScanning,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeSubtitle,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary)),
            ),
            if (isPaused && onResume != null)
              TextButton.icon(
                onPressed: onResume,
                icon: Icon(Icons.play_arrow, size: 18, color: colors.success),
                label: Text(l10n.scanResume,
                    style: TextStyle(color: colors.success)),
              )
            else if (onPause != null)
              TextButton.icon(
                onPressed: onPause,
                icon: Icon(Icons.pause, size: 18, color: colors.primary),
                label: Text(l10n.scanPause,
                    style: TextStyle(color: colors.primary)),
              ),
            if (onCancel != null)
              TextButton(
                onPressed: onCancel,
                child: Text(l10n.scanCancel,
                    style: TextStyle(color: colors.danger)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (driveLabel != null && driveLabel!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Row(
              children: [
                Icon(Icons.storage_rounded, size: 13,
                    color: colors.textHint),
                const SizedBox(width: 4),
                Text(
                  '${l10n.computerScanDrive}: $driveLabel',
                  style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textHint),
                ),
              ],
            ),
          ),
        Text(isPaused ? l10n.scanPaused : s.currentFile,
            style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                color: isPaused ? colors.primary : colors.textHint,
                fontWeight: isPaused ? FontWeight.w600 : FontWeight.normal),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: s.progress,
            minHeight: 6,
            backgroundColor: colors.divider,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.scanChecked}${s.scanned}${l10n.scanOf}${s.total}',
              style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall, color: colors.textHint)),
            if (s.threatsFound > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bug_report, size: 14, color: colors.danger),
                  const SizedBox(width: 3),
                  Text('${s.threatsFound}',
                      style: TextStyle(
                          fontSize: AppTextStyles.sizeSmall,
                          color: colors.danger,
                          fontWeight: FontWeight.w600)),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinished(ScanFinished s, l10n,
      AdaptiveColors colors) {
    final hasThreats = s.threatsFound > 0;
    final color = hasThreats ? colors.danger : colors.success;
    final icon  = hasThreats
        ? Icons.warning_rounded : Icons.check_circle;
    final title = hasThreats
        ? '${l10n.scanThreatsFound}${s.threatsFound}'
        : l10n.scanNoThreats;

    final sec     = s.elapsed.inSeconds;
    final timeStr = sec < 60
        ? l10n.scanTimeSec(sec)
        : l10n.scanTimeMinSec(s.elapsed.inMinutes, sec % 60);

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeSubtitle,
                      fontWeight: FontWeight.w600,
                      color: color)),
              Text(
                '${l10n.scanChecked}${s.scanned} - $timeStr',
                style: TextStyle(
                    fontSize: AppTextStyles.sizeSmall, color: colors.textHint)),
            ],
          ),
        ),
        if (onReset != null)
          TextButton(
            onPressed: onReset,
            child: Text(l10n.scanNewScan,
                style: TextStyle(color: colors.primary)),
          ),
      ],
    );
  }

  Widget _buildError(ScanError e, AdaptiveColors colors) {
    return Row(
      children: [
        Icon(Icons.error_outline, color: colors.danger),
        const SizedBox(width: 12),
        Expanded(
          child: Text(e.message,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeBody,
                  color: colors.textSecondary,
                  height: 1.5)),
        ),
      ],
    );
  }
}

