import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../models/nudge.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/events_provider.dart';
import '../../../providers/nudge_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/nudge_sheet.dart';

enum EventType { clean, update, threat, info, nudge }

class AppEvent {
  final EventType type;
  final String    messageKey;
  final String    time;
  const AppEvent({
      required this.type,
      required this.messageKey,
      required this.time});
}

String _resolveMessage(AppLocalizations l10n, String key) {
  switch (key) {
    case 'homeDbUpdated':
      return l10n.homeDbUpdated;
    case 'eventRealtimeThreatBlocked':
      return l10n.eventRealtimeThreatBlocked;
    case 'eventMemoryThreatsFound':
      return l10n.eventMemoryThreatsFound;
    case 'eventDllInjectionDetected':
      return l10n.eventDllInjectionDetected;
    default:
      return key;
  }
}

class EventsList extends StatelessWidget {
  final VoidCallback? onViewAll;
  const EventsList({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;
    final events = context.watch<EventsProvider>().appEvents;

    final pendingNudges = context.watch<NudgeProvider>().pending;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...pendingNudges.take(3).map((n) => _NudgeBanner(nudge: n, colors: colors, l10n: l10n)),
            if (pendingNudges.isNotEmpty) const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.homeRecentEvents,
                      style: TextStyle(
                          fontSize: AppTextStyles.sizeSubtitle,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary)),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.actionCenterViewAll,
                          style: TextStyle(
                            fontSize: AppTextStyles.sizeSmall,
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            size: 16, color: colors.primary),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(color: colors.divider),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                child: Text(l10n.profileNoEvents,
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeDefault, color: colors.textHint)),
              )
            else
              ...events.take(8).map((e) => _buildTile(e, l10n, colors)),
          ],
        ),
    );
  }

  Widget _buildTile(AppEvent event, AppLocalizations l10n,
      AdaptiveColors colors) {
    final (icon, color) = switch (event.type) {
      EventType.clean  => (Icons.check_circle,    colors.success),
      EventType.update => (Icons.download_done,   colors.primary),
      EventType.threat => (Icons.warning_rounded, colors.danger),
      EventType.info   => (Icons.info_outline,    colors.textHint),
      EventType.nudge  => (Icons.lightbulb_outline, colors.warning),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.s),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_resolveMessage(l10n, event.messageKey),
                style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    color: colors.textPrimary,
                    height: 1.5)),
          ),
          Text(event.time,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  color: colors.textHint)),
        ],
      ),
    );
  }
}


class _NudgeBanner extends StatelessWidget {
  final Nudge          nudge;
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _NudgeBanner({
    required this.nudge,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isUsb = nudge.category == NudgeCategory.usbDevice;
    final usbState = isUsb
        ? context.watch<NudgeProvider>().usbScans[nudge.detail]
        : null;

    final Color accentColor;
    final Widget leadingWidget;
    final String labelText;

    if (!isUsb || usbState == null) {
      accentColor = colors.warning;
      leadingWidget = Icon(Icons.lightbulb_outline, size: 18, color: colors.warning);
      labelText = nudge.detail.isNotEmpty ? nudge.detail : nudge.category.name;
    } else {
      switch (usbState.status) {
        case UsbScanStatus.scanning:
          accentColor = colors.warning;
          leadingWidget = SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.warning),
          );
          labelText = '${nudge.detail} — Сканирую...';
        case UsbScanStatus.complete when usbState.isClean:
          accentColor = colors.success;
          leadingWidget = Icon(Icons.check_circle_outline, size: 18, color: colors.success);
          labelText = '${nudge.detail} — Угроз не найдено';
        case UsbScanStatus.complete:
          accentColor = colors.danger;
          leadingWidget = Icon(Icons.warning_amber_rounded, size: 18, color: colors.danger);
          labelText = '${nudge.detail} — Найдено ${usbState.threats} угроз!';
        case UsbScanStatus.error:
          accentColor = colors.textHint;
          leadingWidget = Icon(Icons.error_outline, size: 18, color: colors.textHint);
          labelText = '${nudge.detail} — Ошибка проверки';
      }
    }

    return GestureDetector(
      onTap: () => NudgeSheet.show(
        context: context,
        nudge: nudge,
        onScanFile: isUsb
            ? () => context.read<NudgeProvider>().retriggerUsbScan(nudge)
            : null,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.s),
        padding: const EdgeInsets.symmetric(
            horizontal: Spacing.m, vertical: Spacing.s + 2),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            leadingWidget,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                labelText,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeBody,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 16, color: accentColor),
          ],
        ),
      ),
    );
  }
}

