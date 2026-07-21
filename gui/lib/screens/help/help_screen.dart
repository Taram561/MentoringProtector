import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../services/module_control_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../utils/snack.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/section_header.dart';
import '../threat_library/threat_library_screen.dart';
import '../hygiene/hygiene_screen.dart';
import '../protection/widgets/smart_cache_stats_sheet.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      Snack.error(context, 'Cannot open: $url');
    }
  }

  Future<void> _reloadYara() async {
    final svc = context.read<ModuleControlService>();
    final ok = await svc.reloadYaraRules();
    if (!mounted) return;
    final strings = context.read<AppStateProvider>().strings;
    if (ok) {
      Snack.success(context, strings.yaraReloadSuccess);
    } else {
      Snack.error(context, strings.yaraReloadFailed);
    }
    context.read<ModuleStatusProvider>().refreshModuleStates();
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 200),
        reverseTransitionDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppStateProvider>();
    final modules = context.watch<ModuleStatusProvider>();
    final l10n    = state.strings;
    final colors  = state.colors;

    return AppTitleBarScaffold(
      title: l10n.helpTitle,
      colors: colors,
      body: ListView(
        padding: Spacing.screenPadding,
        children: [
          AppCard(
            padding: Spacing.cardPadding,
            child: Column(
              children: [
                Icon(Icons.shield_rounded, size: 64, color: colors.primary),
                const SizedBox(height: Spacing.m),
                Text('MentoringProtector',
                    style: AppTextStyles.headline.copyWith(
                        color: colors.textPrimary)),
                const SizedBox(height: Spacing.xs),
                Text('v1.0.0',
                    style: AppTextStyles.body.copyWith(
                        color: colors.textSecondary)),
                const SizedBox(height: Spacing.s),
                Text(
                  l10n.helpMission,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.helpLinksTitle,
            icon: Icons.link,
            colors: colors,
          ),
          AppCard(
            padding: Spacing.cardPadding,
            child: Column(
              children: [
                _LinkTile(
                  icon: Icons.code,
                  title: l10n.helpGithub,
                  onTap: () => _openUrl(
                      'https://github.com/mentoringprotector/mentoringprotector'),
                  colors: colors,
                ),
                const Divider(height: 1),
                _LinkTile(
                  icon: Icons.gavel_outlined,
                  title: l10n.helpLicense,
                  onTap: () => _openUrl(
                      'https://github.com/mentoringprotector/mentoringprotector/blob/main/LICENSE'),
                  colors: colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.helpEducationTitle,
            icon: Icons.school_outlined,
            colors: colors,
          ),
          AppCard(
            padding: Spacing.cardPadding,
            child: Column(
              children: [
                _LinkTile(
                  icon: Icons.menu_book_outlined,
                  title: l10n.helpCourseTitle,
                  subtitle: l10n.helpCourseSoon,
                  onTap: () => Snack.info(context, l10n.helpEducationPlaceholder),
                  colors: colors,
                ),
                const Divider(height: 1),
                _LinkTile(
                  icon: Icons.quiz_outlined,
                  title: l10n.helpQuizTitle,
                  onTap: () => _navigateTo(const HygieneScreen(showAppBar: true)),
                  colors: colors,
                ),
                const Divider(height: 1),
                _LinkTile(
                  icon: Icons.local_library_outlined,
                  title: l10n.threatLibraryTitle,
                  subtitle: l10n.threatLibraryDesc,
                  onTap: () => _navigateTo(const ThreatLibraryScreen()),
                  colors: colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.sectionTechnologies,
            icon: Icons.tune_outlined,
            colors: colors,
          ),
          IconTile(
            icon: Icons.speed_outlined,
            title: l10n.smartScanCacheTitle,
            subtitle: l10n.smartScanCacheDesc,
            iconColor: state.coreReady ? colors.primary : colors.textHint,
            trailing: Icon(
              state.coreReady ? Icons.check_circle : Icons.cancel_outlined,
              color: state.coreReady ? colors.success : colors.danger,
              size: 20,
            ),
            onTap: state.coreReady
                ? () {
                    context.read<ModuleStatusProvider>().refreshSmartCacheStats();
                    SmartCacheStatsSheet.show(context);
                  }
                : null,
            colors: colors,
          ),
          IconTile(
            icon: Icons.verified_outlined,
            title: l10n.trustedReputationTitle,
            subtitle: l10n.trustedReputationDesc,
            iconColor: state.coreReady ? colors.primary : colors.textHint,
            trailing: Icon(
              state.coreReady ? Icons.check_circle : Icons.cancel_outlined,
              color: state.coreReady ? colors.success : colors.danger,
              size: 20,
            ),
            colors: colors,
          ),
          IconTile(
            icon: Icons.rule_outlined,
            title: l10n.yaraRulesTitle,
            subtitle: modules.yaraAvailable
                ? l10n.yaraRulesCount(modules.yaraRulesCount)
                : l10n.yaraUnavailable,
            iconColor: modules.yaraAvailable ? colors.primary : colors.textHint,
            trailing: modules.yaraAvailable
                ? IconButton(
                    icon: Icon(Icons.refresh, color: colors.primary, size: 20),
                    tooltip: l10n.yaraReloadButton,
                    onPressed: _reloadYara,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : Icon(Icons.cancel_outlined, color: colors.danger, size: 20),
            colors: colors,
          ),
          IconTile(
            icon: Icons.insights_outlined,
            title: l10n.etwTitle,
            subtitle: '${l10n.etwDesc}\n${l10n.etwRunAsAdmin}',
            iconColor: colors.textHint,
            trailing: _BadgeChip(
              label: l10n.experimentalBadge,
              color: colors.warning,
            ),
            colors: colors,
          ),
          IconTile(
            icon: Icons.science_outlined,
            title: l10n.sandboxTitle,
            subtitle: l10n.sandboxDescription,
            iconColor: colors.textHint,
            trailing: _BadgeChip(
              label: l10n.sandboxRunningBadge,
              color: colors.accentTeal,
            ),
            colors: colors,
          ),
          IconTile(
            icon: Icons.folder_zip_outlined,
            title: l10n.archiveScannerTitle,
            subtitle: l10n.archiveScannerDescription,
            iconColor: state.coreReady ? colors.primary : colors.textHint,
            trailing: Icon(
              state.coreReady ? Icons.check_circle : Icons.cancel_outlined,
              color: state.coreReady ? colors.success : colors.danger,
              size: 20,
            ),
            colors: colors,
          ),
          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: 'FAQ',
            icon: Icons.help_outline,
            colors: colors,
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _FaqTile(q: l10n.faq01Q, a: l10n.faq01A, colors: colors),
                _FaqTile(q: l10n.faq02Q, a: l10n.faq02A, colors: colors),
                _FaqTile(q: l10n.faq03Q, a: l10n.faq03A, colors: colors),
                _FaqTile(q: l10n.faq04Q, a: l10n.faq04A, colors: colors),
                _FaqTile(q: l10n.faq05Q, a: l10n.faq05A, colors: colors),
                _FaqTile(q: l10n.faq06Q, a: l10n.faq06A, colors: colors),
                _FaqTile(q: l10n.faq07Q, a: l10n.faq07A, colors: colors),
                _FaqTile(q: l10n.faq08Q, a: l10n.faq08A, colors: colors),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;
  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppTextStyles.sizeMicro,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final AdaptiveColors colors;

  const _LinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colors.primary, size: 22),
      title: Text(title, style: AppTextStyles.body.copyWith(
          color: colors.textPrimary)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.caption.copyWith(
              color: colors.textHint))
          : null,
      trailing: Icon(Icons.chevron_right, color: colors.textHint, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.m, vertical: Spacing.xs),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String q;
  final String a;
  final AdaptiveColors colors;

  const _FaqTile({required this.q, required this.a, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(q,
          style: AppTextStyles.body.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w500)),
      iconColor: colors.primary,
      collapsedIconColor: colors.textHint,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Spacing.m, 0, Spacing.m, Spacing.m),
          child: Text(a,
              style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary, height: 1.6)),
        ),
      ],
    );
  }
}

