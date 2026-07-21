import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.g.dart';
import '../../models/archived_report.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/action_status_store.dart';
import '../../services/exclusion_service.dart';
import '../../services/reports_archive_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../utils/snack.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_state.dart';
import '../scan/widgets/threat_detail_sheet.dart';
import '../threat_library/threat_library_screen.dart';
import '../../models/scan_result.dart';
import '../../models/heuristic_result.dart';
import '../../models/threat_info.dart';

class ActionCenterScreen extends StatefulWidget {
  const ActionCenterScreen({super.key});

  @override
  State<ActionCenterScreen> createState() => _ActionCenterScreenState();
}

class _ActionCenterScreenState extends State<ActionCenterScreen> {
  List<ArchivedReport> _reports = [];
  Map<String, IncidentStatus> _statuses = {};
  bool _loading = true;
  String _query = '';
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
    final threats = reports.where((r) => r.dangerLevel > 0).toList();
    final statuses = await ActionStatusStore.instance.loadAll();
    if (!mounted) return;
    setState(() {
      _reports = threats;
      _statuses = statuses;
      _loading = false;
    });
  }

  List<ArchivedReport> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _reports;
    return _reports.where((r) => r.fileName.toLowerCase().contains(q) || r.threatName.toLowerCase().contains(q)).toList();
  }

  Map<String, List<ArchivedReport>> _groupByDate(
      List<ArchivedReport> reports, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final map = <String, List<ArchivedReport>>{};
    for (final r in reports) {
      final d = DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day);
      String key;
      if (d == today) {
        key = l10n.actionCenterGroupToday;
      } else if (d == yesterday) {
        key = l10n.actionCenterGroupYesterday;
      } else {
        key = DateFormat('d MMMM yyyy').format(r.timestamp);
      }
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  Future<void> _setStatus(ArchivedReport r, IncidentStatus status) async {
    await ActionStatusStore.instance.setStatus(r.timestamp.toIso8601String(), status);
    if (!mounted) return;
    setState(() => _statuses[r.timestamp.toIso8601String()] = status);
  }

  IncidentStatus _statusOf(ArchivedReport r) =>
      _statuses[r.timestamp.toIso8601String()] ?? IncidentStatus.pending;

  Future<void> _whitelist(ArchivedReport r, AppLocalizations l10n) async {
    final ok = await ExclusionService().addExclusion(r.filePath);
    if (!mounted) return;
    if (ok) {
      context.read<UserProfileProvider>().recordEvent(
            RiskEventType.threatWhitelisted,
            detail: r.filePath,
          );
      await _setStatus(r, IncidentStatus.whitelisted);
      if (!mounted) return;
      Snack.success(context, l10n.incidentWhitelistSuccess);
    } else {
      Snack.error(context, l10n.incidentWhitelistFailed);
    }
  }

  void _showDetail(ArchivedReport r, AppLocalizations l10n) {
    final sr = _toScanResult(r);
    final status = _statusOf(r);
    final surfaceColor = context.read<AppStateProvider>().colors.surface;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 700),
          child: Material(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ThreatDetailSheet(
              result: sr,
              l10n: l10n,
              onQuarantine: status == IncidentStatus.pending
                  ? () {
                      Navigator.pop(ctx);
                      _setStatus(r, IncidentStatus.quarantined);
                      Snack.success(context, l10n.incidentStatusQuarantined);
                    }
                  : null,
              onIgnore: status == IncidentStatus.pending
                  ? () {
                      Navigator.pop(ctx);
                      _setStatus(r, IncidentStatus.ignored);
                    }
                  : null,
              onWhitelist: status == IncidentStatus.pending
                  ? () {
                      Navigator.pop(ctx);
                      _whitelist(r, l10n);
                    }
                  : null,
              onLearn: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ThreatLibraryScreen()));
              },
            ),
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.watch<AppStateProvider>().colors;

    return AppTitleBarScaffold(
      title: l10n.actionCenterTitle,
      colors: colors,
      body: _loading
          ? LoadingState(colors: colors)
          : _buildContent(l10n, colors),
    );
  }

  Widget _buildContent(AppLocalizations l10n, AdaptiveColors colors) {
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
                    hintText: l10n.actionCenterSearchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (filtered.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.l, vertical: 2),
            child: Row(children: [
              Text(
                l10n.actionCenterCount(filtered.length),
                style: TextStyle(
                    fontSize: AppTextStyles.sizeXSmall,
                    color: colors.textSecondary),
              ),
            ]),
          ),
        const SizedBox(height: Spacing.xs),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.verified_user_outlined,
                  title: l10n.actionCenterEmpty,
                  description: '',
                  colors: colors,
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _buildTimeline(filtered, l10n, colors),
                ),
        ),
      ],
    );
  }

  Widget _buildTimeline(
    List<ArchivedReport> reports,
    AppLocalizations l10n,
    AdaptiveColors colors,
  ) {
    final grouped = _groupByDate(reports, l10n);
    final items = <Widget>[];

    for (final entry in grouped.entries) {
      items.add(_DateHeader(label: entry.key, colors: colors));
      for (final r in entry.value) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.s),
            child: _IncidentCard(
              report: r,
              status: _statusOf(r),
              colors: colors,
              l10n: l10n,
              onTap: () => _showDetail(r, l10n),
              onQuarantine: _statusOf(r) == IncidentStatus.pending
                  ? () async {
                      await _setStatus(r, IncidentStatus.quarantined);
                      if (mounted) {
                        Snack.success(context, l10n.incidentStatusQuarantined);
                      }
                    }
                  : null,
              onWhitelist: _statusOf(r) == IncidentStatus.pending
                  ? () => _whitelist(r, l10n)
                  : null,
              onLearn: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ThreatLibraryScreen())),
              onReEvaluate: _statusOf(r) != IncidentStatus.pending
                  ? () => _setStatus(r, IncidentStatus.pending)
                  : null,
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          Spacing.l, 0, Spacing.l, Spacing.l),
      children: items,
    );
  }

  ScanResult _toScanResult(ArchivedReport r) {
    final extras = r.scanExtras ?? {};
    return ScanResult(
      filePath: r.filePath,
      isInfected: (extras['is_infected'] as bool?) ?? (r.dangerLevel > 0),
      threatName: r.threatName,
      threatType: (extras['threat_type'] as String?) ?? '',
      fileHash: (extras['file_hash'] as String?) ?? '',
      dangerLevel: r.dangerLevel,
      detectionMethod: _parseMethod(r.detectionMethod),
      enginesTriggered:
          ((extras['engines_triggered'] as List?)?.cast<String>() ?? []),
      threatInfo: ThreatInfo.empty(),
      heuristic: HeuristicResult.empty(),
    );
  }

  static DetectionMethod _parseMethod(String s) {
    switch (s) {
      case 'signature':
        return DetectionMethod.signature;
      case 'heuristic':
        return DetectionMethod.heuristic;
      case 'yara':
        return DetectionMethod.yara;
      case 'archiveScan':
        return DetectionMethod.archiveScan;
      default:
        return DetectionMethod.signature;
    }
  }
}


class _DateHeader extends StatelessWidget {
  final String label;
  final AdaptiveColors colors;
  const _DateHeader({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Spacing.m, 0, Spacing.s),
      child: Row(children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTextStyles.sizeSmall,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: colors.textHint.withValues(alpha: 0.4))),
      ]),
    );
  }
}


class _IncidentCard extends StatelessWidget {
  final ArchivedReport report;
  final IncidentStatus status;
  final AdaptiveColors colors;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback? onQuarantine;
  final VoidCallback? onWhitelist;
  final VoidCallback onLearn;
  final VoidCallback? onReEvaluate;

  const _IncidentCard({
    required this.report,
    required this.status,
    required this.colors,
    required this.l10n,
    required this.onTap,
    required this.onQuarantine,
    required this.onWhitelist,
    required this.onLearn,
    required this.onReEvaluate,
  });

  Color _stripeColor() {
    if (report.dangerLevel >= 8) return colors.danger;
    if (report.dangerLevel >= 5) return colors.warning;
    if (report.dangerLevel >= 3) return colors.primary;
    return colors.textHint;
  }

  @override
  Widget build(BuildContext context) {
    final stripe = _stripeColor();
    final fileExists = File(report.filePath).existsSync();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: stripe),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.fileName,
                              style: TextStyle(
                                fontSize: AppTextStyles.sizeBody,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusBadge(status: status, colors: colors, l10n: l10n),
                        ],
                      ),
                      if (report.threatName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          report.threatName,
                          style: TextStyle(
                            fontSize: AppTextStyles.sizeSmall,
                            color: stripe,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.access_time_rounded,
                            size: 12, color: colors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(report.timestamp),
                          style: TextStyle(
                              fontSize: AppTextStyles.sizeXSmall,
                              color: colors.textHint),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.fingerprint_rounded,
                            size: 12, color: colors.textHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.detectionMethod,
                            style: TextStyle(
                                fontSize: AppTextStyles.sizeXSmall,
                                color: colors.textHint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      if (status == IncidentStatus.pending) ...[
                        const SizedBox(height: 8),
                        _ActionRow(
                          showQuarantine: fileExists && onQuarantine != null,
                          onQuarantine: onQuarantine,
                          onWhitelist: onWhitelist,
                          onLearn: onLearn,
                          colors: colors,
                          l10n: l10n,
                        ),
                      ] else if (onReEvaluate != null) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onReEvaluate,
                            child: Text(
                              l10n.incidentReEvaluate,
                              style: TextStyle(
                                  fontSize: AppTextStyles.sizeXSmall,
                                  color: colors.textHint),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ActionRow extends StatelessWidget {
  final bool showQuarantine;
  final VoidCallback? onQuarantine;
  final VoidCallback? onWhitelist;
  final VoidCallback onLearn;
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _ActionRow({
    required this.showQuarantine,
    required this.onQuarantine,
    required this.onWhitelist,
    required this.onLearn,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        if (showQuarantine)
          FilledButton.icon(
            onPressed: onQuarantine,
            icon: const Icon(Icons.shield_rounded, size: 14),
            label: Text(l10n.scanQuarantine),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m, vertical: 6),
              textStyle:
                  const TextStyle(fontSize: AppTextStyles.sizeXSmall,
                      fontWeight: FontWeight.w600),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        if (onWhitelist != null)
          OutlinedButton.icon(
            onPressed: onWhitelist,
            icon: Icon(Icons.shield_outlined, size: 14,
                color: colors.textSecondary),
            label: Text(l10n.btnWhitelist,
                style: TextStyle(color: colors.textSecondary)),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.m, vertical: 6),
              textStyle:
                  const TextStyle(fontSize: AppTextStyles.sizeXSmall),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        OutlinedButton.icon(
          onPressed: onLearn,
          icon: Icon(Icons.menu_book_outlined, size: 14,
              color: colors.textSecondary),
          label: Text(l10n.btnLearn,
              style: TextStyle(color: colors.textSecondary)),
          style: OutlinedButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: Spacing.m, vertical: 6),
            textStyle:
                const TextStyle(fontSize: AppTextStyles.sizeXSmall),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}


class _StatusBadge extends StatelessWidget {
  final IncidentStatus status;
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _StatusBadge({
    required this.status,
    required this.colors,
    required this.l10n,
  });

  Color _badgeColor() {
    switch (status) {
      case IncidentStatus.pending:
        return colors.warning;
      case IncidentStatus.quarantined:
        return colors.success;
      case IncidentStatus.deleted:
        return colors.danger;
      case IncidentStatus.whitelisted:
        return colors.primary;
      case IncidentStatus.ignored:
        return colors.textHint;
    }
  }

  String _label() {
    switch (status) {
      case IncidentStatus.pending:
        return l10n.incidentStatusPending;
      case IncidentStatus.quarantined:
        return l10n.incidentStatusQuarantined;
      case IncidentStatus.deleted:
        return l10n.scanDeleteFile;
      case IncidentStatus.whitelisted:
        return l10n.incidentStatusWhitelisted;
      case IncidentStatus.ignored:
        return l10n.incidentStatusIgnored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _badgeColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.12),
        border: Border.all(color: bg.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _label(),
        style: TextStyle(
          fontSize: AppTextStyles.sizeMicro,
          fontWeight: FontWeight.w600,
          color: bg,
        ),
      ),
    );
  }
}

