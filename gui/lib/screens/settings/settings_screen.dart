import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../theme/spacing.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/section_header.dart';
import '../quarantine/quarantine_screen.dart';
import '../threat_library/threat_library_screen.dart';
import 'exclusion_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onOpenStats;
  const SettingsScreen({super.key, this.onOpenStats});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;
    final mode   = state.themeMode;

    return Scaffold(
      backgroundColor: colors.background,
      body: ListView(
        padding: Spacing.screenPadding,
        children: [

          SectionHeader(
            title: l10n.settingsTheme,
            colors: colors,
            style: SectionHeaderStyle.compact,
          ),
          IconTile(
            icon: Icons.brightness_auto_outlined,
            title: l10n.settingsThemeSystem,
            colors: colors,
            iconColor: mode == ThemeMode.system ? colors.primary : colors.textHint,
            trailing: mode == ThemeMode.system
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
            onTap: () => state.setTheme(ThemeMode.system),
          ),
          IconTile(
            icon: Icons.light_mode_outlined,
            title: l10n.settingsThemeLight,
            colors: colors,
            iconColor: mode == ThemeMode.light ? colors.primary : colors.textHint,
            trailing: mode == ThemeMode.light
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
            onTap: () => state.setTheme(ThemeMode.light),
          ),
          IconTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.settingsThemeDark,
            colors: colors,
            iconColor: mode == ThemeMode.dark ? colors.primary : colors.textHint,
            trailing: mode == ThemeMode.dark
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
            onTap: () => state.setTheme(ThemeMode.dark),
          ),

          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.settingsLanguage,
            colors: colors,
            style: SectionHeaderStyle.compact,
          ),
          IconTile(
            icon: Icons.language,
            title: 'Русский',
            subtitle: 'RU',
            colors: colors,
            iconColor: state.locale == 'ru' ? colors.primary : colors.textHint,
            trailing: state.locale == 'ru'
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
            onTap: () => state.setLocale('ru'),
          ),
          IconTile(
            icon: Icons.language,
            title: 'English',
            subtitle: 'EN',
            colors: colors,
            iconColor: state.locale == 'en' ? colors.primary : colors.textHint,
            trailing: state.locale == 'en'
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
            onTap: () => state.setLocale('en'),
          ),

          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.quarantineTitle,
            colors: colors,
            style: SectionHeaderStyle.compact,
          ),
          IconTile(
            icon: Icons.shield_outlined,
            title: l10n.quarantineTitle,
            subtitle: '${context.watch<ModuleStatusProvider>().quarantineCount} ${l10n.quarantineFile}',
            colors: colors,
            iconColor: colors.warning,
            trailing: Icon(Icons.chevron_right, color: colors.textHint),
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const QuarantineScreen(),
                transitionsBuilder: (_, a, __, child) =>
                    FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
              ),
            ),
          ),

          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.statsScreenTitle,
            colors: colors,
            style: SectionHeaderStyle.compact,
          ),
          IconTile(
            icon: Icons.insights_outlined,
            title: l10n.statsScreenTitle,
            subtitle: l10n.statsScreenSubtitle,
            colors: colors,
            iconColor: colors.primary,
            trailing: Icon(Icons.chevron_right, color: colors.textHint),
            onTap: onOpenStats,
          ),

          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.exclusionListTitle,
            colors: colors,
            style: SectionHeaderStyle.compact,
          ),
          IconTile(
            icon: Icons.playlist_remove,
            title: l10n.exclusionListTitle,
            subtitle: l10n.exclusionListDesc,
            colors: colors,
            iconColor: colors.primary,
            trailing: Icon(Icons.chevron_right, color: colors.textHint),
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ExclusionListScreen(),
                transitionsBuilder: (_, a, __, child) =>
                    FadeTransition(opacity: a, child: child),
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
              ),
            ),
          ),

          const SizedBox(height: Spacing.l),

          SectionHeader(
            title: l10n.threatLibrarySection,
            colors: colors,
            style: SectionHeaderStyle.compact,
          ),
          IconTile(
            icon: Icons.menu_book_outlined,
            title: l10n.threatLibraryTitle,
            subtitle: l10n.threatLibraryDesc,
            iconColor: colors.primary,
            trailing: Icon(Icons.chevron_right, color: colors.textHint, size: 20),
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ThreatLibraryScreen(),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeTransition(opacity: animation, child: child),
                transitionDuration: const Duration(milliseconds: 200),
                reverseTransitionDuration: const Duration(milliseconds: 150),
              ),
            ),
            colors: colors,
          ),

        ],
      ),
    );
  }
}


