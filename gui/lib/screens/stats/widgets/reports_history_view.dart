
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../models/archived_report.dart';
import '../../../providers/app_state_provider.dart';
import '../../../services/reports_archive_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/confirm_dialog.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_state.dart';
import '../../../utils/snack.dart';

class ReportsHistoryView extends StatefulWidget {
  const ReportsHistoryView({super.key});

  @override
  State<ReportsHistoryView> createState() => _ReportsHistoryViewState();
}

class _ReportsHistoryViewState extends State<ReportsHistoryView> {
  List<ArchivedReport> _reports = [];
  bool _loading = true;
  String _query = '';
  ArchivedReportType? _typeFilter;
  final TextEditingController _searchCtl = TextEditingController();
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    ReportsArchiveService.instance.addListener(_onArchiveChanged);
    _load();
  }

  @override
  void dispose() {
    ReportsArchiveService.instance.removeListener(_onArchiveChanged);
    _reloadDebounce?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  void _onArchiveChanged() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final reports = await ReportsArchiveService.instance.loadAll(limit: 500);
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  List<ArchivedReport> get _filtered {
    final q = _query.trim().toLowerCase();
    return _reports.where((r) {
      if (_typeFilter != null && r.type != _typeFilter) return false;
      if (q.isEmpty) return true;
      return r.fileName.toLowerCase().contains(q) || r.threatName.toLowerCase().contains(q) || r.filePath.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    final colors = context.read<AppStateProvider>().colors;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.archiveClearMenu,
      message: l10n.archiveClearConfirm,
      confirmLabel: l10n.archiveClearMenu,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!mounted || !confirmed) return;
    await ReportsArchiveService.instance.clear();
    if (!mounted) return;
    Snack.success(context, l10n.archiveCleared);
    await _load();
  }

  void _showDetails(ArchivedReport r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailSheet(report: r),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final colors = context.watch<AppStateProvider>().colors;

    if (_loading) return LoadingState(colors: colors);

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.l, Spacing.m, Spacing.l, Spacing.s),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l10n.archiveSearchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.s),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: l10n.archiveClearMenu,
                onPressed: _reports.isEmpty ? null : _clear,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: Row(
            children: [
              _filterChip(l10n.archiveFilterAll,      null,                          colors),
              const SizedBox(width: Spacing.s),
              _filterChip(l10n.archiveFilterScan,     ArchivedReportType.scan,       colors),
              const SizedBox(width: Spacing.s),
              _filterChip(l10n.archiveFilterSandbox,  ArchivedReportType.sandbox,    colors),
            ],
          ),
        ),
        const SizedBox(height: Spacing.s),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.history,
                  title: l10n.archiveEmptyTitle,
                  description: l10n.archiveEmptyDescription,
                  colors: colors,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.l, 0, Spacing.l, Spacing.l),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: Spacing.s),
                    itemBuilder: (_, i) =>
                        _ReportCard(report: filtered[i], onTap: _showDetails),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, ArchivedReportType? type, AdaptiveColors colors) {
    final selected = _typeFilter == type;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _typeFilter = type),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ArchivedReport          report;
  final ValueChanged<ArchivedReport> onTap;
  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<AppStateProvider>().colors;
    final isSandbox = report.type == ArchivedReportType.sandbox;
    final severityColor = _severityColor(report.dangerLevel, colors);

    return AppCard(
      onTap: () => onTap(report),
      padding: Spacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: severityColor.withAlpha(38),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSandbox ? Icons.science_outlined : Icons.search,
              color: severityColor,
              size: 22,
            ),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.fileName,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  report.threatName.isEmpty ? '-' : report.threatName,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeSmall,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.m),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${report.dangerLevel}/10',
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontWeight: FontWeight.w600,
                  color: severityColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd.MM HH:mm').format(report.timestamp),
                style: TextStyle(
                  fontSize: AppTextStyles.sizeXSmall,
                  color: colors.textHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor(int dl, AdaptiveColors colors) {
    if (dl >= 9) return colors.severityCritical;
    if (dl >= 6) return colors.severityHigh;
    if (dl >= 3) return colors.severityMedium;
    return colors.primary;
  }
}

class _ReportDetailSheet extends StatelessWidget {
  final ArchivedReport report;
  const _ReportDetailSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<AppStateProvider>().colors;
    final l10n   = AppLocalizations.of(context);
    final isSandbox = report.type == ArchivedReportType.sandbox;
    final data = isSandbox ? report.sandboxData : report.scanExtras;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(Spacing.l),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isSandbox ? Icons.science_outlined : Icons.search,
                  color: colors.primary,
                ),
                const SizedBox(width: Spacing.s),
                Expanded(
                  child: Text(
                    report.fileName,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSubtitle,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: Spacing.s),
            _kv(l10n, 'Тип', isSandbox ? l10n.archiveFilterSandbox : l10n.archiveFilterScan, colors),
            _kv(l10n, 'Путь', report.filePath, colors),
            _kv(l10n, 'Время', DateFormat('dd.MM.yyyy HH:mm:ss').format(report.timestamp), colors),
            _kv(l10n, 'Опасность', '${report.dangerLevel}/10', colors),
            if (report.threatName.isNotEmpty)
              _kv(l10n, 'Угроза', report.threatName, colors),
            _kv(l10n, 'Метод', report.detectionMethod, colors),
            if (data != null) ...[
              const SizedBox(height: Spacing.m),
              Text(
                isSandbox ? 'Детали песочницы' : 'Детали сканирования',
                style: TextStyle(
                  fontSize: AppTextStyles.sizeBody,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.s),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.s),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _pretty(data),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: AppTextStyles.sizeXSmall,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kv(AppLocalizations l10n, String key, String value, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              key,
              style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _pretty(Map<String, dynamic> m) {
    final buf = StringBuffer();
    m.forEach((k, v) {
      if (v is List) {
        buf.writeln('$k:');
        for (final item in v) {
          buf.writeln('  - $item');
        }
      } else {
        buf.writeln('$k: $v');
      }
    });
    return buf.toString();
  }
}

