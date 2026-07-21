import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ffi/core_result.dart';
import '../../l10n/app_localizations.g.dart';
import '../../models/quarantine_entry.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../services/scan_action_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../../utils/snack.dart';

class QuarantineScreen extends StatefulWidget {
  const QuarantineScreen({super.key});
  @override
  State<QuarantineScreen> createState() => _QuarantineScreenState();
}

class _QuarantineScreenState extends State<QuarantineScreen> {
  List<QuarantineEntry> _entries = [];
  bool _isLoading = false;

  ScanActionService get _service => context.read<ScanActionService>();

  @override
  void initState() {
    super.initState();
    _loadQuarantine();
  }

  Future<void> _loadQuarantine() async {
    setState(() => _isLoading = true);
    final list = await _service.getQuarantineList();
    if (!mounted) return;
    setState(() {
      _entries = list.entries;
      _isLoading = false;
    });
    context.read<ModuleStatusProvider>().refreshQuarantineCount();
  }

  Future<void> _restore(String id) async {
    final l10n   = context.read<AppStateProvider>().strings;
    final colors = context.read<AppStateProvider>().colors;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.quarantineRestore,
      message: l10n.quarantineRestoreConfirm,
      confirmLabel: l10n.quarantineRestore,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: false,
    );
    if (!confirmed) return;

    final outcome = await _service.restoreFile(id);
    if (!mounted) return;
    switch (outcome) {
      case QuarantineSuccess():
        Snack.success(context, l10n.quarantineRestoreSuccess);
        await _loadQuarantine();
      case QuarantineFailure(:final message):
        Snack.error(context, message);
    }
  }

  Future<void> _delete(String id) async {
    final l10n   = context.read<AppStateProvider>().strings;
    final colors = context.read<AppStateProvider>().colors;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.quarantineDelete,
      message: l10n.quarantineDeleteConfirm,
      confirmLabel: l10n.quarantineDelete,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!confirmed) return;

    final outcome = await _service.deleteFile(id);
    if (!mounted) return;
    switch (outcome) {
      case QuarantineSuccess():
        await _loadQuarantine();
      case QuarantineFailure(:final message):
        Snack.error(context, message);
    }
  }

  Future<void> _removeOrphan(String id) async {
    final l10n   = context.read<AppStateProvider>().strings;
    final colors = context.read<AppStateProvider>().colors;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.quarantineOrphanRemove,
      message: l10n.quarantineOrphanRemoveConfirm,
      confirmLabel: l10n.quarantineOrphanRemove,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: false,
    );
    if (!confirmed) return;

    final outcome = await _service.deleteFile(id);
    if (!mounted) return;
    switch (outcome) {
      case QuarantineSuccess():
        await _loadQuarantine();
      case QuarantineFailure(:final message):
        Snack.error(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;

    return AppTitleBarScaffold(
      title: l10n.quarantineTitle,
      colors: colors,
      body: _isLoading
          ? LoadingState(colors: colors)
          : _entries.isEmpty
              ? _buildEmpty(l10n, colors)
              : _buildList(l10n, colors),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, AdaptiveColors colors) {
    return EmptyState(
      icon: Icons.shield_outlined,
      title: l10n.quarantineEmpty,
      colors: colors,
    );
  }

  Widget _buildList(AppLocalizations l10n, AdaptiveColors colors) {
    return ListView.separated(
      padding: Spacing.screenPadding,
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: Spacing.s),
      itemBuilder: (_, i) => _buildCard(_entries[i], l10n, colors),
    );
  }

  Widget _buildCard(
      QuarantineEntry e, AppLocalizations l10n, AdaptiveColors colors) {
    final danger = e.dangerLevel;
    final color = danger >= 7
        ? colors.danger
        : danger >= 4 ? colors.warning : colors.success;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 20),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: Text(
                  e.originalName,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                      fontSize: AppTextStyles.sizeBody),
                ),
              ),
              if (e.isOrphan)
                _OrphanBadge(label: l10n.quarantineOrphanBadge, colors: colors)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.s, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$danger/10',
                      style: TextStyle(
                          fontSize: AppTextStyles.sizeXSmall,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
            ]),
            const SizedBox(height: 6),
            Text(e.threatName,
                style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.danger)),
            Text(e.originalPath,
                style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textHint),
                overflow: TextOverflow.ellipsis),
            Text(e.dateQuarantined,
                style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textHint)),
            const SizedBox(height: Spacing.m),
            if (e.isOrphan)
              _buildOrphanActions(e.id, l10n, colors)
            else
              _buildNormalActions(e.id, l10n, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalActions(
      String id, AppLocalizations l10n, AdaptiveColors colors) {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _restore(id),
          icon: const Icon(Icons.restore, size: 16),
          label: Text(l10n.quarantineRestore),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.success,
            side: BorderSide(color: colors.success),
          ),
        ),
      ),
      const SizedBox(width: Spacing.s),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _delete(id),
          icon: const Icon(Icons.delete_forever, size: 16),
          label: Text(l10n.quarantineDelete),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.danger,
            side: BorderSide(color: colors.danger),
          ),
        ),
      ),
    ]);
  }

  Widget _buildOrphanActions(
      String id, AppLocalizations l10n, AdaptiveColors colors) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _removeOrphan(id),
        icon: const Icon(Icons.playlist_remove, size: 16),
        label: Text(l10n.quarantineOrphanRemove),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textHint,
          side: BorderSide(color: colors.textHint),
        ),
      ),
    );
  }
}

class _OrphanBadge extends StatelessWidget {
  const _OrphanBadge({required this.label, required this.colors});
  final String label;
  final AdaptiveColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: 3),
      decoration: BoxDecoration(
        color: colors.textHint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.link_off, size: 10, color: colors.textHint),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: AppTextStyles.sizeXSmall,
                fontWeight: FontWeight.w600,
                color: colors.textHint)),
      ]),
    );
  }
}

