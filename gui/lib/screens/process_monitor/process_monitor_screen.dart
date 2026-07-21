import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../ffi/core_bindings.dart';
import '../../models/dll_injection_alert.dart';
import '../../models/process_alert.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../l10n/app_localizations.g.dart';
import '../../utils/snack.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/bottom_sheet_shell.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_chip.dart';
import 'widgets/process_inspect_sheet.dart';

class ProcessMonitorScreen extends StatefulWidget {
  const ProcessMonitorScreen({super.key});
  @override
  State<ProcessMonitorScreen> createState() =>
      _ProcessMonitorScreenState();
}

class _ProcessMonitorScreenState extends State<ProcessMonitorScreen> {
  final CoreBindings _bindings = CoreBindings.instance;

  bool _isMonitoring = false;
  Timer? _pollTimer;
  List<ProcessAlert> _alerts = [];

  String _monitoringMode = 'off';
  List<DllInjectionAlert> _dllAlerts = [];

  @override
  void initState() {
    super.initState();
    _checkCurrentState();
  }

  void _checkCurrentState() {
    if (_bindings.isMonitoringActive == null) return;
    try {
      final json = _bindings.callReturningString(_bindings.isMonitoringActive!);
      final running = (jsonDecode(json) as Map<String, dynamic>)['active'] == true;
      if (running) {
        setState(() => _isMonitoring = true);
        _pollTimer ??= Timer.periodic(
          const Duration(seconds: 2), (_) => _pollAlerts());
      }
    } catch (e) { debugPrint('[MP] process_monitor error: $e'); }
  }

  Future<void> _startMonitoring() async {
    if (_bindings.startProcessMonitoring == null) {
      Snack.error(context,
          context.read<AppStateProvider>().strings.processFunctionUnavailable);
      return;
    }
    setState(() => _isMonitoring = true);
    try {
      await Future.delayed(const Duration(milliseconds: 50), () {
        _bindings.callReturningString(_bindings.startProcessMonitoring!);
      });
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 2), (_) => _pollAlerts());
      if (mounted) context.read<ModuleStatusProvider>().refreshModuleStates();
    } catch (e) {
      setState(() => _isMonitoring = false);
      if (mounted) {
        Snack.error(context,
            context.read<AppStateProvider>().strings.processErrorPrefix(e.toString()));
      }
    }
  }

  Future<void> _stopMonitoring({bool updateUI = true}) async {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (updateUI && mounted) {
      setState(() => _isMonitoring = false);
    }
    try {
      if (_bindings.stopProcessMonitoring != null) {
        _bindings.callReturningString(_bindings.stopProcessMonitoring!);
      }
    } catch (e) { debugPrint('[MP] process_monitor stop error: $e'); }
    if (mounted) context.read<ModuleStatusProvider>().refreshModuleStates();
  }

  void _pollAlerts() {
    if (_bindings.getProcessAlerts == null) return;
    try {
      final json = _bindings.callReturningString(
          _bindings.getProcessAlerts!);
      if (json.isEmpty) return;
      final map  = jsonDecode(json) as Map<String, dynamic>;
      final list = map['alerts'] as List<dynamic>? ?? [];
      if (list.isNotEmpty) {
        final newAlerts = list
            .map((e) => ProcessAlert.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _alerts.insertAll(0, newAlerts);
          if (_alerts.length > 100) _alerts = _alerts.sublist(0, 100);
        });
      }
    } catch (e) { debugPrint('[MP] process_monitor error: $e'); }

    _pollEtwStatus();
    _pollDllAlerts();
  }

  void _pollEtwStatus() {
    if (_bindings.getEtwStatus == null) return;
    try {
      final json = _bindings.callReturningString(_bindings.getEtwStatus!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final mode = map['mode'] as String? ?? 'off';
      if (mode != _monitoringMode) {
        setState(() => _monitoringMode = mode);
      }
    } catch (e) { debugPrint('[MP] process_monitor error: $e'); }
  }

  void _pollDllAlerts() {
    if (_bindings.getDllInjectionAlerts == null) return;
    try {
      final json = _bindings.callReturningString(
          _bindings.getDllInjectionAlerts!);
      final map = jsonDecode(json) as Map<String, dynamic>;
      final list = map['alerts'] as List<dynamic>? ?? [];
      if (list.isEmpty) return;
      setState(() {
        for (final a in list) {
          _dllAlerts.insert(0, DllInjectionAlert.fromJson(a as Map<String, dynamic>));
        }
        if (_dllAlerts.length > 50) _dllAlerts = _dllAlerts.sublist(0, 50);
      });
    } catch (e) { debugPrint('[MP] process_monitor error: $e'); }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;

    return AppTitleBarScaffold(
      title: l10n.processTitle,
      colors: colors,
      body: Column(
        children: [
          _buildControlPanel(l10n, colors),
          if (_isMonitoring && _dllAlerts.isNotEmpty)
            _buildDllInjectionSection(l10n, colors),
          if (_isMonitoring && _monitoringMode == 'polling')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
              child: Card(
                color: colors.warning.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.m),
                  child: Row(children: [
                    Icon(Icons.admin_panel_settings,
                        color: colors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(l10n.etwRunAsAdmin,
                        style: TextStyle(
                            fontSize: AppTextStyles.sizeSmall, color: colors.warning)),
                    ),
                  ]),
                ),
              ),
            ),
          if (_alerts.isEmpty)
            Expanded(
              child: EmptyState(
                icon: Icons.shield_outlined,
                title: _isMonitoring
                    ? l10n.processNoAlerts
                    : l10n.processStartHint,
                colors: colors,
              ),
            )
          else
            Expanded(child: _buildAlertsList(l10n, colors)),
        ],
      ),
    );
  }

  Widget _buildControlPanel(AppLocalizations l10n, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.all(Spacing.l),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: Spacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.processAnalysisTitle,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeSubtitle,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.processAnalysisDesc,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeBody, color: colors.textSecondary),
            ),
            const SizedBox(height: Spacing.l),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isMonitoring
                    ? _stopMonitoring
                    : _startMonitoring,
                icon: Icon(_isMonitoring
                    ? Icons.stop : Icons.play_arrow),
                label: Text(_isMonitoring
                    ? l10n.processStop
                    : l10n.processStart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isMonitoring
                      ? colors.danger : colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDllInjectionSection(AppLocalizations l10n,
      AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(Spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.security, color: colors.danger, size: 20),
              const SizedBox(width: Spacing.s),
              Text(l10n.etwDllInjectionTitle,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${_dllAlerts.length}',
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeXSmall,
                      fontWeight: FontWeight.w700,
                      color: colors.danger)),
              ),
            ]),
            const SizedBox(height: Spacing.s),
            ..._dllAlerts.take(5).map((a) => _DllAlertTile(
                alert: a, colors: colors)),
            if (_dllAlerts.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  '+${_dllAlerts.length - 5} more...',
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsList(AppLocalizations l10n,
      AdaptiveColors colors) {
    final threats    = _alerts.where((a) => a.isDangerous).toList();
    final suspicious = _alerts.where((a) => a.isSuspicious).toList();
    final clean      = _alerts
        .where((a) => !a.isDangerous && !a.isSuspicious).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      children: [
        _buildStats(threats.length, suspicious.length,
            clean.length, l10n, colors),
        const SizedBox(height: Spacing.s),
        ...threats.map((a) => _ProcessAlertTile(
            alert: a, colors: colors, l10n: l10n)),
        ...suspicious.map((a) => _ProcessAlertTile(
            alert: a, colors: colors, l10n: l10n)),
        ...clean.map((a) => _ProcessAlertTile(
            alert: a, colors: colors, l10n: l10n)),
        const SizedBox(height: Spacing.l),
      ],
    );
  }

  Widget _buildStats(int threats, int suspicious, int clean,
      AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Row(
        children: [
          Expanded(child: StatChip(
            icon: Icons.bug_report,
            value: '$threats',
            label: l10n.processThreats,
            color: colors.danger,
          )),
          const SizedBox(width: Spacing.s),
          Expanded(child: StatChip(
            icon: Icons.warning_amber_rounded,
            value: '$suspicious',
            label: l10n.processSuspicious,
            color: colors.warning,
          )),
          const SizedBox(width: Spacing.s),
          Expanded(child: StatChip(
            icon: Icons.check_circle_outline,
            value: '$clean',
            label: l10n.processClean,
            color: colors.success,
          )),
        ],
      ),
    );
  }
}

class _ProcessAlertTile extends StatelessWidget {
  final ProcessAlert    alert;
  final AdaptiveColors  colors;
  final AppLocalizations l10n;
  const _ProcessAlertTile({
      required this.alert,
      required this.colors,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (true) {
      true when alert.isDangerous  =>
          (colors.danger,  Icons.warning_amber_rounded),
      true when alert.isSuspicious =>
          (colors.warning, Icons.info_outline),
      _ => (colors.success, Icons.check_circle_outline),
    };

    return InkWell(
      onTap: () => _showDetails(context, l10n),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
        padding: const EdgeInsets.all(Spacing.m),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.processName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        fontSize: AppTextStyles.sizeBody)),
                Text(
                  alert.threatName.isNotEmpty
                      ? alert.threatName
                      : '${alert.verdict} • score: '
                        '${alert.suspicionScore}',
                  style: TextStyle(color: color, fontSize: AppTextStyles.sizeSmall)),
                Text('PID: ${alert.pid} • ${alert.detectedAt}',
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeSmall,
                        color: colors.textSecondary)),
              ],
            ),
          ),
          if (alert.isBlocked)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.s, vertical: 3),
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(l10n.processBlocked,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeXSmall,
                      fontWeight: FontWeight.w700,
                      color: colors.danger)),
            ),
          const SizedBox(width: Spacing.xs),
          Icon(Icons.chevron_right,
              color: color.withValues(alpha: 0.5), size: 18),
        ]),
      ),
    );
  }

  void _showDetails(BuildContext context, AppLocalizations l10n) {
    final bindings = CoreBindings.instance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => BottomSheetShell(
        colors: colors,
        child: Padding(
          padding: Spacing.sheetPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(alert.isDangerous ? Icons.warning_amber_rounded
                    : Icons.info_outline,
                  color: alert.isDangerous ? colors.danger : colors.warning,
                  size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text(alert.processName,
                  style: TextStyle(fontSize: AppTextStyles.sizeSubtitle, fontWeight: FontWeight.bold,
                      color: colors.textPrimary))),
              ]),
              const Divider(height: 24),
              _row('PID', '${alert.pid}'),
              _rowCopyable(sheetCtx, l10n.processPathLabel, alert.exePath, l10n),
              _row(l10n.processVerdictLabel, alert.verdict),
              _row(l10n.processDangerLevel, '${alert.dangerLevel}/10'),
              _row(l10n.processSuspicionScore, '${alert.suspicionScore}/100'),
              if (alert.threatName.isNotEmpty)
                _row(l10n.processThreatLabel, alert.threatName),
              _row(l10n.processDetectionMethod, alert.detectionMethod.name),
              if (alert.triggeredRules.isNotEmpty)
                _row(l10n.processRulesLabel, alert.triggeredRules.join(', ')),
              if (alert.fileHash.isNotEmpty)
                _rowCopyable(sheetCtx, l10n.processHashLabel, alert.fileHash, l10n),
              const SizedBox(height: Spacing.l),

              if (!alert.isBlocked && (alert.isDangerous || alert.isSuspicious))
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          title: l10n.processTerminate,
                          message: '${alert.processName} (PID: ${alert.pid})',
                          confirmLabel: l10n.processTerminate,
                          cancelLabel: l10n.btnCancel,
                          colors: colors,
                          isDestructive: true,
                        );
                        if (!confirmed) return;
                        if (bindings.terminateProcessByPid != null) {
                          final ptr = bindings.terminateProcessByPid!(alert.pid);
                          bindings.freeString(ptr);
                        }
                        if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                        if (context.mounted) {
                          Snack.success(context,
                              l10n.processTerminatedMsg(alert.processName));
                        }
                      },
                      icon: const Icon(Icons.block, size: 18),
                      label: Text(l10n.processTerminate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.danger,
                        foregroundColor: colors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.m),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(sheetCtx),
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(l10n.processAllow),
                    ),
                  ),
                ]),
              const SizedBox(height: Spacing.s),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetCtx);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ProcessInspectSheet(pid: alert.pid),
                    );
                  },
                  icon: Icon(Icons.manage_search_rounded,
                      size: 18, color: colors.primary),
                  label: Text(l10n.inspectButton,
                      style: TextStyle(color: colors.primary)),
                ),
              ),
              if (alert.isBlocked)
                Center(child: Text(l10n.processWasTerminated,
                  style: TextStyle(color: colors.danger,
                      fontWeight: FontWeight.w600))),
              const SizedBox(height: Spacing.s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 160, child: Text(label,
          style: TextStyle(fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary,
            fontWeight: FontWeight.w500))),
        Expanded(child: SelectableText(value,
          style: const TextStyle(fontSize: AppTextStyles.sizeDefault),
          maxLines: 3)),
      ]),
    );
  }

  Widget _rowCopyable(BuildContext ctx, String label, String value,
      AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 160, child: Text(label,
          style: TextStyle(fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary,
            fontWeight: FontWeight.w500))),
        Expanded(child: SelectableText(value,
          style: const TextStyle(fontSize: AppTextStyles.sizeDefault, fontFamily: 'monospace'),
          maxLines: 3)),
        if (value.isNotEmpty)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Snack.info(ctx, l10n.copiedToClipboard,
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

class _DllAlertTile extends StatelessWidget {
  final DllInjectionAlert alert;
  final AdaptiveColors colors;
  const _DllAlertTile({
      required this.alert,
      required this.colors});

  @override
  Widget build(BuildContext context) {
    final dllPath = alert.dllPath;
    final reason  = alert.reason;
    final pid     = alert.pid;
    final process = alert.processName.isNotEmpty ? alert.processName : 'PID $pid';
    final score   = alert.score;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(Spacing.s),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.danger.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.warning_amber_rounded,
                color: colors.danger, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(process,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeDefault,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary),
                overflow: TextOverflow.ellipsis),
            ),
            Text('score: $score',
              style: TextStyle(
                  fontSize: AppTextStyles.sizeXSmall,
                  fontWeight: FontWeight.w600,
                  color: colors.danger)),
          ]),
          const SizedBox(height: Spacing.xs),
          Text(dllPath,
            style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          if (reason.isNotEmpty)
            Text(reason,
              style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.danger),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

