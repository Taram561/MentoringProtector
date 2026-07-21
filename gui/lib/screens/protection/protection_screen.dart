import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ffi/app_paths.dart';
import '../../ffi/core_bindings.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../services/module_control_service.dart';
import '../../services/helper_bridge.dart';
import '../../utils/snack.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/section_header.dart';
import '../vulnerability/vuln_screen.dart';
import '../process_monitor/process_monitor_screen.dart';
import '../memory_scan/memory_scan_screen.dart';
import '../web_protection/web_protection_screen.dart';
import '../realtime_monitor/realtime_monitor_screen.dart';
import '../action_center/action_center_screen.dart';

class ProtectionScreen extends StatefulWidget {
  const ProtectionScreen({super.key});
  @override
  State<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends State<ProtectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ModuleStatusProvider>().refreshModuleStates();
    });
  }

  void _refreshStates() {
    context.read<ModuleStatusProvider>().refreshModuleStates();
  }

  Future<void> _toggleRealtime(bool value) async {
    if (CoreBindings.isInitialized && CoreBindings.instance.serviceHosting) {
      final res = await HelperBridge.runServiceCmd(value ? 'realtime_start' : 'realtime_stop');
      if (!mounted) return;
      if (!res.userCancelled && !res.ok) {
        Snack.error(context, context.read<AppStateProvider>().strings.serviceCmdFailed);
      }
      _refreshStates();
      return;
    }
    final svc = context.read<ModuleControlService>();
    if (value) { svc.startRealtime(); } else { svc.stopRealtime(); }
    _refreshStates();
  }

  void _toggleProcess(bool value) {
    final svc = context.read<ModuleControlService>();
    if (value) { svc.startProcessMonitoring(); } else { svc.stopProcessMonitoring(); }
    _refreshStates();
  }

  Future<void> _toggleWeb(bool value) async {
    if (CoreBindings.isInitialized && CoreBindings.instance.serviceHosting) {
      final res = await HelperBridge.runServiceCmd(value ? 'web_start' : 'web_stop');
      if (!mounted) return;
      if (!res.userCancelled && !res.ok) {
        Snack.error(context, context.read<AppStateProvider>().strings.serviceCmdFailed);
      }
      _refreshStates();
      return;
    }
    final svc = context.read<ModuleControlService>();
    if (value) {
      svc.startWebProtection(AppPaths.phishingDomainsPath, AppPaths.safeDomainsPath);
    } else {
      svc.stopWebProtection();
    }
    _refreshStates();
  }

  void _toggleMemoryScan(bool value) {
    final svc = context.read<ModuleControlService>();
    if (value) { svc.startMemoryScan(); } else { svc.stopMemoryScan(); }
    _refreshStates();
  }

  Future<void> _navigateTo(Widget screen) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      ),
    );
    _refreshStates();
  }

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppStateProvider>();
    final modules = context.watch<ModuleStatusProvider>();
    final l10n    = state.strings;
    final colors  = state.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: ListView(
        padding: Spacing.screenPadding,
        children: [
          SectionHeader(
            title: l10n.sectionBasicProtection,
            icon: Icons.shield_outlined,
            colors: colors,
          ),
          _ProtectionTile(
            icon: Icons.security_outlined,
            activeIcon: Icons.security,
            title: l10n.realtimeTitle,
            subtitle: l10n.realtimeDescription,
            isActive: modules.realtimeActive,
            onToggle: _toggleRealtime,
            onTap: () => _navigateTo(const RealtimeMonitorScreen()),
            colors: colors,
          ),
          _ProtectionTile(
            icon: Icons.language_outlined,
            activeIcon: Icons.language,
            title: l10n.webTitle,
            subtitle: l10n.webDescription,
            isActive: modules.webActive,
            onToggle: _toggleWeb,
            onTap: () => _navigateTo(const WebProtectionScreen()),
            colors: colors,
          ),
          const SizedBox(height: Spacing.xl),

          SectionHeader(
            title: l10n.sectionAdvancedProtection,
            icon: Icons.admin_panel_settings_outlined,
            colors: colors,
          ),
          _ProtectionTile(
            icon: Icons.monitor_heart_outlined,
            activeIcon: Icons.monitor_heart,
            title: l10n.processTitle,
            subtitle: l10n.processAnalysisDesc,
            isActive: modules.processActive,
            onToggle: _toggleProcess,
            onTap: () => _navigateTo(const ProcessMonitorScreen()),
            colors: colors,
          ),
          _ProtectionTile(
            icon: Icons.memory_outlined,
            activeIcon: Icons.memory,
            title: l10n.memoryTitle,
            subtitle: l10n.memoryDescription,
            isActive: modules.memoryScanActive,
            onToggle: _toggleMemoryScan,
            onTap: () => _navigateTo(const MemoryScanScreen()),
            colors: colors,
          ),
          _ProtectionTile(
            icon: Icons.bug_report_outlined,
            activeIcon: Icons.bug_report,
            title: l10n.vulnTitle,
            subtitle: l10n.vulnDescription,
            isActive: false,
            onToggle: null,
            onTap: () => _navigateTo(const VulnScreen()),
            colors: colors,
            showArrow: true,
          ),
          _ProtectionTile(
            icon: Icons.crisis_alert_outlined,
            activeIcon: Icons.crisis_alert,
            title: l10n.actionCenterTitle,
            subtitle: l10n.actionCenterViewAll,
            isActive: false,
            onToggle: null,
            onTap: () => _navigateTo(const ActionCenterScreen()),
            colors: colors,
            showArrow: true,
          ),

        ],
      ),
    );
  }
}

class _ProtectionTile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final bool isActive;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final AdaptiveColors colors;
  final bool showArrow;

  const _ProtectionTile({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onToggle,
    required this.onTap,
    required this.colors,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l, vertical: Spacing.m),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isActive ? colors.primary : colors.textHint)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? colors.primary : colors.textHint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title,
                              style: TextStyle(
                                  fontSize: AppTextStyles.sizeBody,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary)),
                        ),
                        if (onToggle != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: (isActive ? colors.success : colors.danger)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(isActive ? 'ON' : 'OFF',
                                style: TextStyle(
                                    fontSize: AppTextStyles.sizeMicro,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? colors.success
                                        : colors.danger)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (onToggle != null)
                SizedBox(
                  height: 28,
                  child: FittedBox(
                    child: Switch(
                      value: isActive,
                      onChanged: onToggle,
                      activeThumbColor: colors.primary,
                    ),
                  ),
                ),
              if (showArrow)
                Icon(Icons.chevron_right,
                    color: colors.textHint, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

