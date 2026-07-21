import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../models/archived_report.dart';
import '../../../models/sandbox_report.dart';
import '../../../models/scan_result.dart';
import '../../../providers/app_state_provider.dart';
import '../../../services/reports_archive_service.dart';
import '../../../services/sandbox_service.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../utils/snack.dart';

class SandboxReportSheet extends StatefulWidget {
  final SandboxService service;
  final AppLocalizations l10n;
  final ScanResult? scanResult;

  const SandboxReportSheet({
    super.key,
    required this.service,
    required this.l10n,
    this.scanResult,
  });

  @override
  State<SandboxReportSheet> createState() => _SandboxReportSheetState();
}

class _SandboxReportSheetState extends State<SandboxReportSheet> {
  Timer?         _pollTimer;
  String _state = 'running';
  int _elapsed = 0;
  SandboxReport? _report;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
  }

  Future<void> _poll() async {
    final status = await widget.service.getStatus();
    final newState   = status['state'] as String? ?? 'idle';
    final newElapsed = status['elapsed'] as int?  ?? 0;

    if (!mounted) return;

    if (newState == 'completed' || newState == 'cancelled') {
      _pollTimer?.cancel();
      final report = await widget.service.getReport();
      if (!mounted) return;
      setState(() {
        _state = newState;
        _elapsed = newElapsed;
        _report = report;
      });
      final sr = widget.scanResult;
      if (sr != null) {
        ReportsArchiveService.instance
            .append(ArchivedReport.fromSandboxRun(sr, report))
            .catchError((e) => debugPrint('[MP] archive sandbox: $e'));
      }
    } else if (newState == 'error') {
      _pollTimer?.cancel();
      if (mounted) {
        Snack.error(context, widget.l10n.sandboxError);
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _state = newState;
        _elapsed = newElapsed;
      });
    }
  }

  Future<void> _cancel() async {
    _pollTimer?.cancel();
    await widget.service.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: colors.surface,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetHandle(colors: colors),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: _SheetHeader(
                l10n: widget.l10n,
                state: _state,
                colors: colors,
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: _state == 'running' || _state == 'idle'
                    ? _RunningBody(
                        elapsed: _elapsed,
                        l10n: widget.l10n,
                        colors: colors,
                        onCancel: _cancel,
                      )
                    : _ReportBody(
                        report: _report ?? SandboxReport.empty(),
                        l10n: widget.l10n,
                        colors: colors,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  final AdaptiveColors colors;
  const _SheetHandle({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: colors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String state;
  final AdaptiveColors colors;
  const _SheetHeader({required this.l10n, required this.state, required this.colors});

  @override
  Widget build(BuildContext context) {
    final done = state == 'completed' || state == 'cancelled';
    return Row(
      children: [
        Icon(
          done ? Icons.science : Icons.hourglass_top_outlined,
          color: done ? colors.accentTeal : colors.warning,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.sandboxReport,
            style: TextStyle(
              fontSize: AppTextStyles.sizeMedium,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _RunningBody extends StatelessWidget {
  final int elapsed;
  final AppLocalizations l10n;
  final AdaptiveColors colors;
  final VoidCallback onCancel;

  const _RunningBody({
    required this.elapsed,
    required this.l10n,
    required this.colors,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    const int timeout = 60;
    final fraction = (elapsed / timeout).clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: Spacing.m),
        CircularProgressIndicator(
          value: fraction > 0 ? fraction : null,
          color: colors.accentTeal,
          strokeWidth: 3,
        ),
        const SizedBox(height: Spacing.l),
        Text(
          l10n.sandboxRunning,
          style: TextStyle(
            fontSize: AppTextStyles.sizeDefault,
            color: colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '$elapsed / $timeout s',
          style: TextStyle(
            fontSize: AppTextStyles.sizeSmall,
            color: colors.textHint,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: Spacing.xl),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: Text(l10n.sandboxCancel),
          ),
        ),
      ],
    );
  }
}

class _ReportBody extends StatelessWidget {
  final SandboxReport report;
  final AppLocalizations l10n;
  final AdaptiveColors colors;

  const _ReportBody({
    required this.report,
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final score = report.riskScore;
    final scoreColor = _scoreColor(score, colors);
    final eventGroups = _groupEvents(report.events);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RiskScoreBar(score: score, color: scoreColor, colors: colors, l10n: l10n),
        const SizedBox(height: Spacing.m),

        Row(
          children: [
            Icon(Icons.timer_outlined, size: 14, color: colors.textHint),
            const SizedBox(width: 4),
            Text(
              '${report.durationSeconds}s${report.timedOut ? ' (timeout)' : ''}',
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                color: colors.textHint,
              ),
            ),
          ],
        ),

        if (report.riskIndicators.isNotEmpty) ...[
          const SizedBox(height: Spacing.m),
          _SectionLabel(label: l10n.sandboxRiskIndicators, icon: Icons.warning_amber_outlined, color: scoreColor),
          const SizedBox(height: Spacing.xs),
          ...report.riskIndicators.map((ind) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 6, color: scoreColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ind,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],

        for (final entry in eventGroups.entries) ...[
          const SizedBox(height: Spacing.m),
          _SectionLabel(
            label: _eventTypeLabel(entry.key, l10n),
            icon: _eventTypeIcon(entry.key),
            color: _eventTypeColor(entry.key, colors),
          ),
          const SizedBox(height: Spacing.xs),
          ...entry.value.map((ev) => _EventTile(event: ev, colors: colors)),
        ],

        if (report.events.isEmpty && report.riskIndicators.isEmpty) ...[
          const SizedBox(height: Spacing.m),
          Center(
            child: Text(
              l10n.sandboxNoBehaviour,
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                color: colors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Color _scoreColor(int score, AdaptiveColors colors) {
    if (score >= 70) return colors.danger;
    if (score >= 40) return colors.warning;
    return colors.success;
  }

  Map<String, List<BehavioralEvent>> _groupEvents(List<BehavioralEvent> events) {
    final Map<String, List<BehavioralEvent>> groups = {};
    for (final e in events) {
      groups.putIfAbsent(e.type, () => []).add(e);
    }
    return groups;
  }

  static String _eventTypeLabel(String type, AppLocalizations l10n) => switch (type) { 'process_create' => l10n.sandboxChildProcesses, 'module_load' => l10n.sandboxLoadedModules, 'memory_spike' => l10n.sandboxMemorySpikes, _ => type };

  static IconData _eventTypeIcon(String type) => switch (type) { 'process_create' => Icons.account_tree_outlined, 'module_load' => Icons.extension_outlined, 'memory_spike' => Icons.memory_outlined, _ => Icons.info_outline };

  static Color _eventTypeColor(String type, AdaptiveColors colors) => switch (type) { 'process_create' => colors.danger, 'module_load' => colors.warning, 'memory_spike' => colors.accentPurple, _ => colors.textSecondary };
}

class _RiskScoreBar extends StatelessWidget {
  final int score;
  final Color color;
  final AdaptiveColors colors;
  final AppLocalizations l10n;
  const _RiskScoreBar({required this.score, required this.color, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.sandboxRiskScore,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                )),
            Text('$score / 100',
                style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  fontWeight: FontWeight.w700,
                  color: color,
                )),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionLabel({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
              fontSize: AppTextStyles.sizeDefault,
              fontWeight: FontWeight.w600,
              color: color,
            )),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  final BehavioralEvent event;
  final AdaptiveColors colors;
  const _EventTile({required this.event, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xs, left: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.target,
            style: TextStyle(
              fontSize: AppTextStyles.sizeSmall,
              fontFamily: 'monospace',
              color: colors.textPrimary,
            ),
          ),
          if (event.detail.isNotEmpty)
            Text(
              event.detail,
              style: TextStyle(
                fontSize: AppTextStyles.sizeTiny,
                color: colors.textHint,
              ),
            ),
        ],
      ),
    );
  }
}

