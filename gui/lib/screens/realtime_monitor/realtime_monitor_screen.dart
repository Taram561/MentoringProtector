import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ffi/core_bindings.dart';
import '../../services/helper_bridge.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/dll_injection_alert.dart';
import '../../models/realtime_event.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../l10n/app_localizations.g.dart';
import '../../utils/snack.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/stat_chip.dart';
import '../home/widgets/events_list.dart';

class RealtimeMonitorScreen extends StatefulWidget {
  const RealtimeMonitorScreen({super.key});
  @override
  State<RealtimeMonitorScreen> createState() => _RealtimeMonitorScreenState();
}

class _RealtimeMonitorScreenState extends State<RealtimeMonitorScreen> {
  CoreBindings? _bindings;

  bool _isRunning = false;
  bool _dllSupported = false;
  Timer? _pollTimer;
  int _totalDetected = 0;
  int _threatsFound = 0;
  int _lastNotifiedThreatCount = 0;
  List<RealtimeEvent> _events = [];
  List<DllInjectionAlert> _dllAlerts = [];

  @override
  void initState() {
    super.initState();
    _bindings = CoreBindings.isInitialized ? CoreBindings.instance : null;
    _checkCurrentState();
  }

  void _checkCurrentState() {
    if (_bindings?.isRealtimeMonitoring == null) return;
    try {
      final json = _bindings!.callReturningString(_bindings!.isRealtimeMonitoring!);
      final running = (jsonDecode(json) as Map<String, dynamic>)['active'] == true;
      if (running) {
        setState(() => _isRunning = true);
        _pollTimer ??= Timer.periodic(
          const Duration(seconds: 2), (_) => _pollEvents());
      }
    } catch (e) { debugPrint('[MP] realtime_monitor error: $e'); }
  }

  Future<void> _start() async {
    if (CoreBindings.isInitialized && CoreBindings.instance.serviceHosting) {
      setState(() {
        _isRunning = true;
        _lastNotifiedThreatCount = 0;
        _dllAlerts.clear();
      });
      final res = await HelperBridge.runServiceCmd('realtime_start');
      if (!mounted) return;
      if (res.userCancelled || !res.ok) {
        setState(() => _isRunning = false);
        if (!res.userCancelled) {
          debugPrint('[MP] runServiceCmd failed: ok=${res.ok} message=${res.message}');
          Snack.error(context, context.read<AppStateProvider>().strings.serviceCmdFailed);
        }
        return;
      }
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollEvents());
      context.read<ModuleStatusProvider>().refreshModuleStates();
      context.read<UserProfileProvider>().recordEvent(
        RiskEventType.protectionEnabled, detail: 'realtime_monitor');
      return;
    }
    if (_bindings?.startRealtimeMonitor == null) {
      Snack.error(context, context.read<AppStateProvider>().strings.realtimeUnavailable);
      return;
    }
    setState(() {
      _isRunning = true;
      _lastNotifiedThreatCount = 0;
      _dllAlerts.clear();
    });
    try {
      await Future.delayed(const Duration(milliseconds: 50), () {
        _bindings!.callReturningString(_bindings!.startRealtimeMonitor!);
      });
      if (_bindings?.getEtwStatus != null) {
        try {
          final etwJson = _bindings!.callReturningString(_bindings!.getEtwStatus!);
          final etwMap = jsonDecode(etwJson) as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _dllSupported = etwMap['dll_injection_supported'] == true;
            });
          }
        } catch (e) { debugPrint('[MP] RealtimeMonitor ETW status: $e'); }
      }
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(
        const Duration(seconds: 2), (_) => _pollEvents());
      if (mounted) {
        context.read<ModuleStatusProvider>().refreshModuleStates();
        context.read<UserProfileProvider>().recordEvent(
          RiskEventType.protectionEnabled, detail: 'realtime_monitor');
      }
    } catch (e) {
      setState(() => _isRunning = false);
      if (mounted) Snack.error(context, e.toString());
    }
  }

  Future<void> _stop() async {
    if (CoreBindings.isInitialized && CoreBindings.instance.serviceHosting) {
      _pollTimer?.cancel();
      _pollTimer = null;
      setState(() {
        _isRunning = false;
        _dllSupported = false;
      });
      final res = await HelperBridge.runServiceCmd('realtime_stop');
      if (!mounted) return;
      if (res.userCancelled || !res.ok) {
        setState(() => _isRunning = true);
        _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollEvents());
        if (!res.userCancelled) {
          debugPrint('[MP] runServiceCmd failed: ok=${res.ok} message=${res.message}');
          Snack.error(context, context.read<AppStateProvider>().strings.serviceCmdFailed);
        }
        return;
      }
      context.read<ModuleStatusProvider>().refreshModuleStates();
      context.read<UserProfileProvider>().recordEvent(
        RiskEventType.protectionDisabled, detail: 'realtime_monitor');
      return;
    }
    _pollTimer?.cancel();
    _pollTimer = null;
    setState(() {
      _isRunning = false;
      _dllSupported = false;
    });
    try {
      if (_bindings?.stopRealtimeMonitor != null) {
        _bindings!.callReturningString(_bindings!.stopRealtimeMonitor!);
      }
    } catch (e) { debugPrint('[MP] realtime_monitor error: $e'); }
    if (mounted) {
      context.read<ModuleStatusProvider>().refreshModuleStates();
      context.read<UserProfileProvider>().recordEvent(
        RiskEventType.protectionDisabled, detail: 'realtime_monitor');
    }
  }

  void _pollEvents() {
    if (_bindings?.getRealtimeEvents == null) return;
    try {
      final json = _bindings!.callReturningString(
          _bindings!.getRealtimeEvents!);
      if (json.isEmpty) return;
      final map = jsonDecode(json) as Map<String, dynamic>;

      final totalDetected = map['total_detected'] as int? ?? 0;
      final threatsFound = map['threats_found'] as int? ?? 0;
      final list = map['events'] as List<dynamic>? ?? [];

      if (list.isEmpty && totalDetected == _totalDetected) {
        _pollDllAlerts();
        return;
      }

      setState(() {
        _totalDetected = totalDetected;
        _threatsFound = threatsFound;
        for (final e in list) {
          _events.insert(0, RealtimeEvent.fromJson(e as Map<String, dynamic>));
        }
        if (_events.length > 200) _events = _events.sublist(0, 200);
      });

      if (threatsFound > _lastNotifiedThreatCount && mounted) {
        _lastNotifiedThreatCount = threatsFound;
        final now = TimeOfDay.now();
        context.read<EventsProvider>().addEvent(AppEvent(
          type: EventType.threat,
          messageKey: 'eventRealtimeThreatBlocked',
          time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ));
      }
    } catch (e) { debugPrint('[MP] realtime_monitor error: $e'); }
    _pollDllAlerts();
  }

  void _pollDllAlerts() {
    if (!_dllSupported || _bindings?.getDllInjectionAlerts == null) return;
    try {
      final json = _bindings!.callReturningString(
          _bindings!.getDllInjectionAlerts!);
      if (json.isEmpty) return;
      final map = jsonDecode(json) as Map<String, dynamic>;
      final count = map['count'] as int? ?? 0;
      if (count <= 0) return;

      final alerts = (map['alerts'] as List<dynamic>? ?? [])
          .map((a) => DllInjectionAlert.fromJson(a as Map<String, dynamic>))
          .toList();

      setState(() {
        for (final a in alerts) {
          _dllAlerts.insert(0, a);
        }
        if (_dllAlerts.length > 50) _dllAlerts = _dllAlerts.sublist(0, 50);
      });

      if (mounted) {
        final now = TimeOfDay.now();
        context.read<EventsProvider>().addEvent(AppEvent(
          type: EventType.threat,
          messageKey: 'eventDllInjectionDetected',
          time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ));
      }
    } catch (e) { debugPrint('[MP] dll_alerts error: $e'); }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pollTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    return AppTitleBarScaffold(
      title: l10n.realtimeTitle,
      colors: colors,
      body: Column(children: [
        _buildControlPanel(l10n, colors),
        if (_isRunning && _events.isNotEmpty)
          _buildStats(l10n, colors),
        if (_isRunning && _dllSupported)
          _buildDllAlertsCard(l10n, colors),
        if (_events.isEmpty)
          Expanded(
            child: EmptyState(
              icon: Icons.folder_open_outlined,
              title: _isRunning ? l10n.realtimeNoEvents : l10n.realtimeStartHint,
              colors: colors,
            ),
          )
        else
          Expanded(child: _buildEventsList(l10n, colors)),
      ]),
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
            Text(l10n.realtimeTitle,
                style: TextStyle(fontSize: AppTextStyles.sizeSubtitle, fontWeight: FontWeight.w600,
                    color: colors.textPrimary)),
            const SizedBox(height: Spacing.xs),
            Text(l10n.realtimeDescription,
                style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textSecondary)),
            const SizedBox(height: Spacing.l),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? _stop : _start,
                icon: Icon(_isRunning ? Icons.shield : Icons.shield_outlined),
                label: Text(_isRunning ? l10n.realtimeStop : l10n.realtimeStart),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? colors.danger : colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(AppLocalizations l10n, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, Spacing.s),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: Spacing.cardPadding,
        child: Row(
          children: [
            Expanded(child: StatChip(
              icon: Icons.radar,
              value: '$_totalDetected',
              label: l10n.realtimeTotalDetected,
              color: colors.primary,
            )),
            const SizedBox(width: Spacing.s),
            Expanded(child: StatChip(
              icon: Icons.warning_amber_rounded,
              value: '$_threatsFound',
              label: l10n.realtimeThreatsFound,
              color: _threatsFound > 0 ? colors.danger : colors.success,
            )),
            const SizedBox(width: Spacing.s),
            Expanded(child: StatChip(
              icon: Icons.list_alt_outlined,
              value: '${_events.length}',
              label: l10n.realtimeEvents,
              color: colors.textSecondary,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDllAlertsCard(AppLocalizations l10n, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, Spacing.s),
      child: Container(
        padding: Spacing.cardPadding,
        decoration: BoxDecoration(
          color: colors.warning.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.warning.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.memory_outlined, color: colors.warning, size: 18),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: Text(
                  l10n.dllInjectionAlertsTitle,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeDefault,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (_dllAlerts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_dllAlerts.length}',
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeTiny,
                      fontWeight: FontWeight.w700,
                      color: colors.warning,
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: Spacing.s),
            if (_dllAlerts.isEmpty)
              Text(
                l10n.dllInjectionEmptyState,
                style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
              )
            else
              ..._dllAlerts.take(5).map((a) => _DllAlertTile(alert: a, colors: colors, l10n: l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(AppLocalizations l10n, AdaptiveColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final e = _events[index];

        final (color, icon) = e.isThreat
            ? (colors.danger, Icons.warning_amber_rounded)
            : e.verdict == 'suspicious'
                ? (colors.warning, Icons.info_outline)
                : (colors.success, Icons.check_circle_outline);

        final actionLabel = switch (e.action) {
          'created' => l10n.realtimeCreated,
          'modified' => l10n.realtimeModified,
          'renamed' => l10n.realtimeRenamed,
          _ => e.action,
        };

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.all(Spacing.m),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.fileName,
                      style: TextStyle(fontWeight: FontWeight.w600,
                          color: colors.textPrimary, fontSize: AppTextStyles.sizeDefault),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (e.isThreat && e.threatName.isNotEmpty)
                    Text(e.threatName,
                        style: TextStyle(color: color, fontSize: AppTextStyles.sizeSmall)),
                  Text('$actionLabel | ${e.detectedAt}'
                      '${e.score > 0 ? " | score: ${e.score}" : ""}',
                      style: TextStyle(fontSize: AppTextStyles.sizeXSmall,
                          color: colors.textSecondary)),
                ],
              ),
            ),
            if (e.isThreat)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.s, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(e.verdict.toUpperCase(),
                    style: TextStyle(fontSize: AppTextStyles.sizeTiny,
                        fontWeight: FontWeight.w700, color: colors.danger)),
              ),
          ]),
        );
      },
    );
  }
}


class _DllAlertTile extends StatelessWidget {
  final DllInjectionAlert alert;
  final AdaptiveColors    colors;
  final AppLocalizations  l10n;

  const _DllAlertTile({
    required this.alert,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(Spacing.s),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(Icons.warning_amber_rounded, color: colors.warning, size: 16),
        const SizedBox(width: Spacing.s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${alert.processName} (PID: ${alert.pid})',
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                alert.dllPath,
                style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${alert.reason} | ${l10n.dllInjectionScoreLabel}: ${alert.score} | ${alert.detectedAt}',
                style: TextStyle(fontSize: AppTextStyles.sizeTiny, color: colors.textHint),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

