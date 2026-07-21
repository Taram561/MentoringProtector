import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/module_status_provider.dart';
import '../../../services/smart_cache_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../utils/snack.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/stat_chip.dart';

class SmartCacheStatsSheet extends StatefulWidget {
  const SmartCacheStatsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SmartCacheStatsSheet(),
    );
  }

  @override
  State<SmartCacheStatsSheet> createState() => _SmartCacheStatsSheetState();
}

class _SmartCacheStatsSheetState extends State<SmartCacheStatsSheet> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ModuleStatusProvider>().refreshSmartCacheStats();
    });
  }

  bool get _coreAvailable => context.read<SmartCacheService>().isAvailable;

  Future<void> _onInvalidate() async {
    final state = context.read<AppStateProvider>();
    final svc   = context.read<SmartCacheService>();
    setState(() => _loading = true);
    try {
      final ok = await svc.invalidateCache();
      if (!mounted) return;
      if (ok) {
        Snack.success(context, state.strings.cacheInvalidateSuccess);
        context.read<ModuleStatusProvider>().refreshSmartCacheStats();
      } else {
        Snack.error(context, state.strings.cacheInvalidateFailed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onClear() async {
    final state = context.read<AppStateProvider>();
    final svc   = context.read<SmartCacheService>();
    final colors = state.colors;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: state.strings.cacheClearConfirmTitle,
      message: state.strings.cacheClearConfirmMsg,
      confirmLabel: state.strings.cacheClearConfirm,
      cancelLabel: state.strings.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _loading = true);
    try {
      final ok = await svc.clearCache();
      if (!mounted) return;
      if (ok) {
        Snack.success(context, state.strings.cacheClearSuccess);
        context.read<ModuleStatusProvider>().refreshSmartCacheStats();
      } else {
        Snack.error(context, state.strings.cacheClearFailed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppStateProvider>();
    final modules = context.watch<ModuleStatusProvider>();
    final colors  = state.colors;
    final l10n    = state.strings;
    final stats   = modules.smartCacheStats;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(
          Spacing.l, Spacing.l, Spacing.l, Spacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: colors.textHint.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Spacing.m),
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.speed_outlined, color: colors.primary, size: 20),
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.smartScanCacheTitle,
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeLabel,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      l10n.smartScanCacheDesc,
                      style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colors.textHint, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: Spacing.l),

          if (!_coreAvailable) ...[
            Container(
              padding: Spacing.cardPadding,
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: colors.warning, size: 18),
                  const SizedBox(width: Spacing.s),
                  Expanded(
                    child: Text(
                      l10n.cacheCoreUnavailable,
                      style: TextStyle(
                          fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.m),
          ],

          Row(
            children: [
              Expanded(
                child: StatChip(
                  icon: Icons.check_circle_outline,
                  value: stats.hits.toString(),
                  label: l10n.cacheStatsHits,
                  color: colors.success,
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: StatChip(
                  icon: Icons.cancel_outlined,
                  value: stats.misses.toString(),
                  label: l10n.cacheStatsMisses,
                  color: colors.danger,
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: StatChip(
                  icon: Icons.storage_outlined,
                  value: stats.entries.toString(),
                  label: l10n.cacheStatsEntries,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m),

          _HitRateBar(rate: stats.hitRate, colors: colors, l10n: l10n),
          const SizedBox(height: Spacing.s),

          Row(
            children: [
              Icon(Icons.refresh, size: 14, color: colors.textHint),
              const SizedBox(width: 4),
              Text(
                '${l10n.cacheStatsInvalidations}: ${stats.invalidations}',
                style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.l),
          const Divider(),
          const SizedBox(height: Spacing.m),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading || !_coreAvailable
                      ? null
                      : _onInvalidate,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.cacheInvalidateButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading || !_coreAvailable
                      ? null
                      : _onClear,
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  label: Text(l10n.cacheClearButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(
                        color: colors.danger.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  ),
                ),
              ),
            ],
          ),

          if (_loading) ...[
            const SizedBox(height: Spacing.m),
            LinearProgressIndicator(
              color: colors.primary,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
            ),
          ],
        ],
      ),
    );
  }
}

class _HitRateBar extends StatelessWidget {
  final double rate;
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _HitRateBar({required this.rate, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final pct = rate.clamp(0.0, 100.0);
    final barColor = pct >= 70
        ? colors.success
        : pct >= 40
            ? colors.warning
            : colors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.cacheStatsHitRate,
              style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
            ),
            Text(
              '${pct.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: AppTextStyles.sizeXSmall,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100.0,
            backgroundColor: colors.textHint.withValues(alpha: 0.12),
            color: barColor,
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

