import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.g.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../utils/snack.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/user_profile.dart';
import 'widgets/active_engines_chip.dart';
import 'widgets/status_card.dart';
import 'widgets/events_list.dart';
import 'widgets/db_status_card.dart';
import 'widgets/security_profile_card.dart';
import 'widgets/stats_preview_card.dart';
import '../hygiene/quiz_suggestion.dart';
import '../threat_library/threat_library_entry_card.dart';
import '../action_center/action_center_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onScanPressed;
  final VoidCallback? onOpenStats;
  const HomeScreen({
    super.key,
    required this.onScanPressed,
    this.onOpenStats,
  });

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppStateProvider>();
    final modules = context.watch<ModuleStatusProvider>();
    final l10n    = state.strings;
    final colors  = state.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Spacing.l, Spacing.l, Spacing.l, Spacing.xl),
        children: [
          StatusCard(
            status: modules.activeModulesCount >= 2
                ? ProtectionStatus.protected
                : modules.activeModulesCount >= 1
                    ? ProtectionStatus.warning
                    : ProtectionStatus.danger,
            lastScanText: state.lastScanDate.isNotEmpty
                ? '${l10n.homeLastScan}${state.lastScanDate}'
                : l10n.homeLastScan,
            onScanPressed: onScanPressed,
          ),
          const SizedBox(height: Spacing.m),
          const ActiveEnginesChip(),
          const SizedBox(height: Spacing.m),
          _ProtectionToggleButton(colors: colors, l10n: l10n),
          const SizedBox(height: Spacing.l),
          SecurityProfileCard(colors: colors, l10n: l10n),
          const SizedBox(height: Spacing.l),
          const DbStatusCard(),
          const SizedBox(height: Spacing.l),
          EventsList(
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ActionCenterScreen()),
            ),
          ),
          const SizedBox(height: Spacing.m),
          StatsPreviewCard(onOpen: onOpenStats ?? () {}),
          const SizedBox(height: Spacing.m),
          const ThreatLibraryEntryCard(),
        ],
      ),
    );
  }
}

class _ProtectionToggleButton extends StatelessWidget {
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _ProtectionToggleButton({required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final modules   = context.watch<ModuleStatusProvider>();
    final allActive = modules.allProtectionActive;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final profileProvider = context.read<UserProfileProvider>();
          if (allActive) {
            modules.disableAllProtection();
            profileProvider.recordEvent(
              RiskEventType.protectionDisabled,
              detail: 'disable_all',
            );
            Snack.error(context, l10n.allProtectionDisabled);
            suggestQuizForEvent(context, RiskEventType.protectionDisabled);
          } else {
            final count = modules.enableAllProtection();
            if (count > 0) {
              profileProvider.recordEvent(
                RiskEventType.protectionEnabled,
                detail: 'enable_all:$count modules',
              );
            }
            Snack.success(context, l10n.allProtectionEnabled);
          }
        },
        icon: Icon(
          allActive ? Icons.shield_outlined : Icons.shield,
          size: 20,
        ),
        label: Text(
          allActive ? l10n.disableAllProtection : l10n.enableAllProtection,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: allActive ? colors.danger : colors.success,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: Spacing.l),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: AppTextStyles.sizeLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

