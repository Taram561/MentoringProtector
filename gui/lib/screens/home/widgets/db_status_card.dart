import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/db_status_provider.dart';
import '../../../providers/events_provider.dart';
import '../../../services/db_updater.dart';
import '../../../theme/spacing.dart';
import '../../../utils/snack.dart';
import '../../../widgets/app_card.dart';
import 'events_list.dart';
import '../../../theme/app_theme.dart';

class DbStatusCard extends StatelessWidget {
  const DbStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state    = context.watch<AppStateProvider>();
    final dbState  = context.watch<DbStatusProvider>();
    final l10n     = state.strings;
    final colors   = state.colors;

    final lastUpdate = dbState.lastDbUpdate;
    final isOutdated = dbState.dbIsOutdated;
    final isUpdating = dbState.dbUpdating;

    final statusColor = lastUpdate == null
        ? colors.danger
        : isOutdated
            ? colors.warning
            : colors.success;

    final statusText = lastUpdate == null
        ? l10n.dbStatusNeverUpdated
        : isOutdated
            ? l10n.dbStatusOutdated
            : l10n.dbStatusUpdated;

    final dateText = lastUpdate != null
        ? '${lastUpdate.day.toString().padLeft(2, '0')}.'
          '${lastUpdate.month.toString().padLeft(2, '0')}.'
          '${lastUpdate.year} '
          '${lastUpdate.hour.toString().padLeft(2, '0')}:'
          '${lastUpdate.minute.toString().padLeft(2, '0')}'
        : '-';

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.storage_rounded,
                      color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.dbStatusTitle,
                          style: TextStyle(
                              fontSize: AppTextStyles.sizeSubtitle,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(statusText,
                              style: TextStyle(
                                  fontSize: AppTextStyles.sizeDefault,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: colors.textHint),
                const SizedBox(width: 6),
                Text('${l10n.dbStatusLastUpdate}: ',
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary)),
                Text(dateText,
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeDefault,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isUpdating ? null : () => _updateDb(context),
                icon: isUpdating
                    ? SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: colors.primary))
                    : Icon(Icons.refresh, size: 18, color: colors.primary),
                label: Text(
                  isUpdating ? l10n.dbStatusUpdating : l10n.dbStatusUpdate,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    fontWeight: FontWeight.w600,
                    color: isUpdating ? colors.textHint : colors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _updateDb(BuildContext context) async {
    final dbState = context.read<DbStatusProvider>();
    dbState.setDbUpdating(true);
    try {
      final result = await DartCvdDownloader.fetchAndApply();
      if (!context.mounted) return;
      if (result.success) {
        dbState.setDbUpdated();
        final now = DateTime.now();
        context.read<EventsProvider>().addEvent(AppEvent(
          type: EventType.update,
          messageKey: 'homeDbUpdated',
          time: '${now.hour.toString().padLeft(2, '0')}:'
                '${now.minute.toString().padLeft(2, '0')}',
        ));
        if (result.usedFallback) {
          Snack.info(context, context.read<AppStateProvider>().strings.dbUpdateFellBackPython);
        }
      } else {
        dbState.setDbUpdating(false);
        Snack.error(context, result.message);
        debugPrint('[MP] DB update failed: ${result.message}');
      }
    } catch (e) {
      if (!context.mounted) return;
      dbState.setDbUpdating(false);
      Snack.error(context, context.read<AppStateProvider>().strings.errorGeneric);
      debugPrint('[MP] DB update error: $e');
    }
  }
}

