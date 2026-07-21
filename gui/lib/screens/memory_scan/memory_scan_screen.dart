import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../ffi/core_bindings.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../providers/events_provider.dart';
import '../../models/memory_threat.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../l10n/app_localizations.g.dart';
import '../../utils/snack.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/stat_chip.dart';
import '../home/widgets/events_list.dart';

class MemoryScanScreen extends StatefulWidget {
  const MemoryScanScreen({super.key});
  @override
  State<MemoryScanScreen> createState() => _MemoryScanScreenState();
}

class _MemoryScanScreenState extends State<MemoryScanScreen> {
  final CoreBindings _bindings = CoreBindings.instance;

  bool _isRunning = false;
  bool _isFinished = false;
  bool _scanCompleteEventAdded = false;
  Timer? _pollTimer;
  int _processesTotal = 0;
  int _processesScanned = 0;
  int _threatsFound = 0;
  String _currentProcess = '';
  List<MemoryThreat> _threats = [];

  @override
  void initState() {
    super.initState();
    _checkCurrentState();
  }

  void _checkCurrentState() {
    if (_bindings.getMemoryScanProgress == null) return;
    try {
      final json = _bindings.callReturningString(_bindings.getMemoryScanProgress!);
      if ((jsonDecode(json) as Map<String, dynamic>)['is_running'] == true) {
        setState(() => _isRunning = true);
        _pollTimer ??= Timer.periodic(
          const Duration(milliseconds: 500), (_) => _pollProgress());
      }
    } catch (e) { debugPrint('[MP] memory_scan error: $e'); }
  }

  Future<void> _startScan() async {
    if (_bindings.startMemoryScan == null) {
      Snack.error(context, context.read<AppStateProvider>().strings.memoryUnavailable);
      return;
    }
    setState(() {
      _isRunning = true;
      _isFinished = false;
      _scanCompleteEventAdded = false;
      _threats.clear();
      _processesScanned = 0;
      _threatsFound = 0;
    });
    try {
      await Future.delayed(const Duration(milliseconds: 50), () {
        _bindings.callReturningString(_bindings.startMemoryScan!);
      });
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
          const Duration(milliseconds: 500), (_) => _pollProgress());
      if (mounted) context.read<ModuleStatusProvider>().refreshModuleStates();
    } catch (e) {
      setState(() => _isRunning = false);
      if (mounted) Snack.error(context, e.toString());
    }
  }

  void _stopScan() {
    _pollTimer?.cancel();
    _pollTimer = null;
    try {
      if (_bindings.stopMemoryScan != null) {
        _bindings.callReturningString(_bindings.stopMemoryScan!);
      }
    } catch (e) { debugPrint('[MP] memory_scan error: $e'); }
    setState(() => _isRunning = false);
    if (mounted) context.read<ModuleStatusProvider>().refreshModuleStates();
  }

  void _pollProgress() {
    if (_bindings.getMemoryScanProgress == null) return;
    try {
      final json = _bindings.callReturningString(
          _bindings.getMemoryScanProgress!);
      if (json.isEmpty) return;
      final map = jsonDecode(json) as Map<String, dynamic>;

      setState(() {
        _isRunning = map['is_running'] == true;
        _isFinished = map['is_finished'] == true;
        _processesTotal = map['processes_total'] as int? ?? 0;
        _processesScanned = map['processes_scanned'] as int? ?? 0;
        _threatsFound = map['threats_found'] as int? ?? 0;
        _currentProcess = map['current_process'] as String? ?? '';

        final threatList = map['threats'] as List<dynamic>? ?? [];
        if (threatList.isNotEmpty) {
          _threats = threatList
              .map((e) => MemoryThreat.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });

      if (_isFinished) {
        _pollTimer?.cancel();
        _pollTimer = null;
        if (_threatsFound > 0 && !_scanCompleteEventAdded && mounted) {
          _scanCompleteEventAdded = true;
          final now = TimeOfDay.now();
          context.read<EventsProvider>().addEvent(AppEvent(
            type: EventType.threat,
            messageKey: 'eventMemoryThreatsFound',
            time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          ));
        }
      }
    } catch (e) { debugPrint('[MP] memory_scan error: $e'); }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    return AppTitleBarScaffold(
      title: l10n.memoryTitle,
      colors: colors,
      body: ListView(
        padding: Spacing.screenPadding,
        children: [
          _buildControlCard(l10n, colors),
          if (_isRunning || _isFinished) ...[
            const SizedBox(height: Spacing.m),
            _buildProgressCard(l10n, colors),
          ],
          if (_threats.isNotEmpty) ...[
            const SizedBox(height: Spacing.m),
            _buildThreatsCard(l10n, colors),
          ],
          if (_isFinished && _threats.isEmpty) ...[
            const SizedBox(height: Spacing.xl),
            _buildCleanResult(l10n, colors),
          ],
        ],
      ),
    );
  }

  Widget _buildControlCard(AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.memory, color: colors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.memoryTitle,
                      style: TextStyle(fontSize: AppTextStyles.sizeSubtitle,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary)),
                  Text(l10n.memoryDescription,
                      style: TextStyle(fontSize: AppTextStyles.sizeDefault,
                          color: colors.textSecondary)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: Spacing.l),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? _stopScan : _startScan,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(_isRunning
                  ? l10n.memoryScanStop : l10n.memoryScanStart),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRunning
                    ? colors.danger : colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppLocalizations l10n, AdaptiveColors colors) {
    final progress = _processesTotal > 0
        ? _processesScanned / _processesTotal
        : 0.0;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isFinished
                  ? l10n.memoryScanFinished
                  : l10n.memoryScanRunning,
                  style: TextStyle(fontSize: AppTextStyles.sizeLabel,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary)),
              Text('$_processesScanned / $_processesTotal',
                  style: TextStyle(fontSize: AppTextStyles.sizeBody,
                      color: colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _isFinished ? 1.0 : progress,
              minHeight: 8,
              backgroundColor: colors.primary.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(
                  _isFinished ? colors.success : colors.primary),
            ),
          ),
          const SizedBox(height: 10),
          if (_currentProcess.isNotEmpty && !_isFinished)
            Text('${l10n.memoryScanCurrentProcess}: $_currentProcess',
                style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: Spacing.s),
          Row(
            children: [
              Expanded(child: StatChip(
                icon: Icons.memory_outlined,
                value: '$_processesScanned',
                label: l10n.memoryScanProcesses,
                color: colors.primary,
              )),
              const SizedBox(width: Spacing.m),
              Expanded(child: StatChip(
                icon: Icons.warning_amber_rounded,
                value: '$_threatsFound',
                label: l10n.memoryScanThreatsFound,
                color: _threatsFound > 0 ? colors.danger : colors.success,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThreatsCard(AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l10n.memoryScanThreatsFound}: ${_threats.length}',
              style: TextStyle(fontSize: AppTextStyles.sizeLabel,
                  fontWeight: FontWeight.w600, color: colors.danger)),
          const SizedBox(height: 10),
          ..._threats.map((t) {
            return InkWell(
              onTap: () => _showThreatDetails(context, t, colors, l10n),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
                padding: const EdgeInsets.all(Spacing.m),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          color: colors.danger, size: 20),
                      const SizedBox(width: Spacing.s),
                      Expanded(
                        child: Text('${t.processName} (PID: ${t.pid})',
                            style: TextStyle(fontWeight: FontWeight.w600,
                                color: colors.textPrimary, fontSize: AppTextStyles.sizeBody)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.s, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${l10n.memoryScanMatches}: ${t.matchesCount}',
                            style: TextStyle(fontSize: AppTextStyles.sizeTiny,
                                fontWeight: FontWeight.w700,
                                color: colors.danger)),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Icon(Icons.chevron_right,
                          color: colors.danger.withValues(alpha: 0.5), size: 18),
                    ]),
                    if (t.threatName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 28),
                        child: Text(t.threatName,
                            style: TextStyle(
                                color: colors.danger, fontSize: AppTextStyles.sizeDefault)),
                      ),
                    if (t.matchedSignatures.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 28),
                        child: Wrap(
                          spacing: 6, runSpacing: 4,
                          children: t.matchedSignatures.map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s,
                                style: TextStyle(fontSize: AppTextStyles.sizeXSmall,
                                    color: colors.danger)),
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCleanResult(AppLocalizations l10n, AdaptiveColors colors) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.verified_user, size: 64, color: colors.success),
          const SizedBox(height: Spacing.m),
          Text(l10n.memoryScanNoThreats,
              style: TextStyle(fontSize: AppTextStyles.sizeSubtitle, color: colors.success,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showThreatDetails(BuildContext ctx, MemoryThreat t,
      AdaptiveColors colors, dynamic l10n) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemoryThreatSheet(threat: t),
    );
  }
}


class _MemoryThreatSheet extends StatefulWidget {
  final MemoryThreat threat;
  const _MemoryThreatSheet({required this.threat});

  @override
  State<_MemoryThreatSheet> createState() => _MemoryThreatSheetState();
}

class _MemoryThreatSheetState extends State<_MemoryThreatSheet> {
  bool _busy = false;

  Future<void> _onTerminate() async {
    final state = context.read<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;
    final pid = widget.threat.pid;
    if (pid <= 0) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.memoryTerminateConfirmTitle,
      message: l10n.memoryTerminateConfirmMsg,
      confirmLabel: l10n.memoryActionTerminate,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      final b = CoreBindings.instance;
      if (b.terminateProcessByPid == null) {
        if (!mounted) return;
        Snack.error(context, l10n.memoryActionFailed);
        return;
      }
      final json = b.callWithIntArg(b.terminateProcessByPid!, pid);
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (!mounted) return;
      if (map['success'] == true) {
        Snack.success(context, l10n.memoryActionSuccess);
        Navigator.of(context).pop();
      } else {
        Snack.error(context,
            '${l10n.memoryActionFailed}: ${map['error'] ?? ''}');
      }
    } catch (e) {
      if (!mounted) return;
      Snack.error(context, l10n.memoryActionFailed);
      debugPrint('[MP] terminate error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onQuarantine() async {
    final state = context.read<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;
    final exePath = widget.threat.exePath;
    if (exePath.isEmpty) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.memoryQuarantineConfirmTitle,
      message: l10n.memoryQuarantineConfirmMsg,
      confirmLabel: l10n.memoryActionQuarantine,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    try {
      final b = CoreBindings.instance;
      if (b.quarantineFile == null) {
        if (!mounted) return;
        Snack.error(context, l10n.memoryActionFailed);
        return;
      }
      final threatName  = widget.threat.threatName.isEmpty
          ? 'memory_threat' : widget.threat.threatName;
      final dangerLevel = widget.threat.dangerLevel;
      final json = b.callQuarantineFile(
        b.quarantineFile!,
        exePath,
        threatName,
        'malware',
        dangerLevel,
      );
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (!mounted) return;
      if (map['success'] == true) {
        Snack.success(context, l10n.memoryActionSuccess);
        Navigator.of(context).pop();
      } else {
        Snack.error(context, l10n.memoryActionFailed);
      }
    } catch (e) {
      if (!mounted) return;
      Snack.error(context, l10n.memoryActionFailed);
      debugPrint('[MP] quarantine error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final colors = state.colors;
    final l10n = state.strings;

    final name      = widget.threat.processName;
    final threatName = widget.threat.threatName;
    final pid        = widget.threat.pid;
    final matches    = widget.threat.matchesCount;
    final exePath    = widget.threat.exePath;
    final memScanned = widget.threat.memoryScanned;
    final regions    = widget.threat.regionsScanned;
    final sigs       = widget.threat.matchedSignatures;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: Spacing.sheetPadding,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Spacing.m),
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(children: [
              Icon(Icons.memory, color: colors.danger, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$name (PID: $pid)',
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeSubtitle,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ]),
            const Divider(height: 24),
            _infoRow(l10n.memThreatLabel, threatName, colors),
            _infoRowCopyable(l10n.memPathLabel, exePath, l10n, colors),
            _infoRow(l10n.memMatchesLabel, '$matches', colors),
            _infoRow(l10n.memRegionsLabel, '$regions', colors),
            _infoRow(
              l10n.memMemoryScanned,
              '${(memScanned / 1024 / 1024).toStringAsFixed(1)} ${l10n.memMb}',
              colors,
            ),
            if (sigs.isNotEmpty) ...[
              const SizedBox(height: Spacing.s),
              Text(l10n.memDetectedSignatures,
                  style: const TextStyle(
                      fontSize: AppTextStyles.sizeDefault, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: sigs
                    .map((s) => Chip(
                          label: Text(s,
                              style: const TextStyle(fontSize: AppTextStyles.sizeXSmall)),
                          backgroundColor:
                              colors.danger.withValues(alpha: 0.1),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: Spacing.l),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _onTerminate,
                  icon: const Icon(Icons.stop_circle_outlined, size: 16),
                  label: Text(l10n.memoryActionTerminate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(
                        color: colors.danger.withValues(alpha: 0.4)),
                    padding:
                        const EdgeInsets.symmetric(vertical: Spacing.m),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.m),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy || exePath.isEmpty ? null : _onQuarantine,
                  icon: const Icon(Icons.shield_outlined, size: 16),
                  label: Text(l10n.memoryActionQuarantine),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.4)),
                    padding:
                        const EdgeInsets.symmetric(vertical: Spacing.m),
                  ),
                ),
              ),
            ]),
            if (_busy) ...[
              const SizedBox(height: Spacing.m),
              LinearProgressIndicator(
                color: colors.primary,
                backgroundColor: colors.primary.withValues(alpha: 0.1),
              ),
            ],
            const SizedBox(height: Spacing.l),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 150,
          child: Text(label,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: SelectableText(value,
              style: const TextStyle(fontSize: AppTextStyles.sizeDefault), maxLines: 3),
        ),
      ]),
    );
  }

  Widget _infoRowCopyable(
      String label, String value, AppLocalizations l10n, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 150,
          child: Text(label,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: SelectableText(value,
              style: const TextStyle(fontSize: AppTextStyles.sizeDefault, fontFamily: 'monospace'),
              maxLines: 3),
        ),
        if (value.isNotEmpty)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Snack.info(context, l10n.copiedToClipboard,
                  duration: const Duration(seconds: 1));
            },
            icon: const Icon(Icons.copy, size: 14),
            tooltip: l10n.copyPath,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            style: IconButton.styleFrom(foregroundColor: colors.primary),
          ),
      ]),
    );
  }
}

