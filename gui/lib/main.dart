import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'providers/app_state_provider.dart';
import 'providers/module_status_provider.dart';
import 'providers/db_status_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/events_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/nudge_provider.dart';
import 'models/nudge.dart';
import 'widgets/nudge_sheet.dart';
import 'l10n/app_localizations.g.dart';
import 'theme/app_theme.dart';
import 'ffi/app_paths.dart';
import 'ffi/core_bindings.dart';
import 'screens/home/home_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/protection/protection_screen.dart';
import 'screens/stats/stats_dashboard_screen.dart';
import 'screens/hygiene/hygiene_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'widgets/app_title_bar.dart';
import 'services/threat_education_service.dart';
import 'services/scan_action_service.dart';
import 'services/exclusion_service.dart';
import 'services/smart_cache_service.dart';
import 'services/vuln_service.dart';
import 'services/module_control_service.dart';
import 'services/db_updater.dart';
import 'services/reports_archive_service.dart';


void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(900, 600),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Mentoring Protector',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logCrash('FlutterError: ${details.exceptionAsString()}\n${details.stack}');
    };

    final initResult = CoreBindings.tryInitialize();

    ThreatEducationService.instance.load();

    runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppStateProvider()),
            ChangeNotifierProvider(create: (_) => ModuleStatusProvider()),
            ChangeNotifierProvider(create: (_) => DbStatusProvider()),
            ChangeNotifierProvider(create: (_) => StatsProvider()),
            ChangeNotifierProvider(create: (_) => EventsProvider()),
            ChangeNotifierProvider(create: (_) => UserProfileProvider()),
            ChangeNotifierProxyProvider<UserProfileProvider, NudgeProvider>(
              create: (ctx) => NudgeProvider(profileProvider: ctx.read<UserProfileProvider>()),
              update: (ctx, profile, prev) => prev ?? NudgeProvider(profileProvider: profile),
            ),
            Provider<ScanActionService>(create: (_) => ScanActionService()),
            Provider<ExclusionService>(create: (_) => ExclusionService()),
            Provider<SmartCacheService>(create: (_) => SmartCacheService()),
            Provider<VulnService>(create: (_) => VulnService()),
            Provider<ModuleControlService>(create: (_) => ModuleControlService()),
          ],
          child: MentoringProtectorApp(initResult: initResult),
                    ),
          );

    Future<void>.delayed(Duration.zero, () async {
      unawaited(_ensureYaraDll());
      unawaited(ReportsArchiveService.instance.cleanDuplicates());
      final sigIntegrity = await DartCvdDownloader.verifySignaturesOnStartup();
      if (sigIntegrity != null) {
        _logCrash('SECURITY: $sigIntegrity');
        debugPrint('[MP] SECURITY: $sigIntegrity');
      }
    });
  }, (error, stack) {
    debugPrint('[MP] Uncaught error: $error');
    _logCrash('Uncaught: $error\n$stack');
  });
}

Future<void> _ensureYaraDll() async {
  const yaraDlls = ['yara.dll', 'libyara64.dll'];
  try {
    final cwd = Directory.current.path;
    for (final config in ['Debug', 'Release', 'Profile']) {
      final dir = Directory(p.join(cwd, 'build', 'windows', 'x64', 'runner', config));
      if (!dir.existsSync()) continue;
      for (final name in yaraDlls) {
        final src = File(p.join(AppPaths.dataDir, name));
        if (!src.existsSync()) continue;
        final target = File(p.join(dir.path, name));
        if (!target.existsSync()) await src.copy(target.path);
      }
      final buildDataDir = Directory(p.join(dir.path, 'data'));
      if (!buildDataDir.existsSync()) continue;

      final sigSrc = File(p.join(AppPaths.dataDir, 'signatures.msdb'));
      final sigTarget = File(p.join(buildDataDir.path, 'signatures.msdb'));
      if (sigSrc.existsSync() && (!sigTarget.existsSync() || sigSrc.lastModifiedSync().isAfter(sigTarget.lastModifiedSync()))) {
        await sigSrc.copy(sigTarget.path);
      }

      final rulesTarget = Directory(p.join(dir.path, 'data', 'yara_rules'));
      final rulesSrc = Directory(p.join(AppPaths.dataDir, 'yara_rules'));
      if (!rulesSrc.existsSync()) continue;

      if (!rulesTarget.existsSync()) {
        await rulesTarget.create(recursive: true);
        await for (final entity in rulesSrc.list()) {
          if (entity is File) {
            final ruleName = p.basename(entity.path);
            await entity.copy(p.join(rulesTarget.path, ruleName));
          }
        }
      }

      final srcCompiled = File(p.join(AppPaths.dataDir, 'yara_rules', 'compiled_rules.yrc'));
      final buildCompiled = File(p.join(rulesTarget.path, 'compiled_rules.yrc'));
      if (!srcCompiled.existsSync() && buildCompiled.existsSync()) {
        await buildCompiled.delete();
      }

      final dllFile = File(p.join(dir.path, 'mentoring_protector_core.dll'));
      if (buildCompiled.existsSync() && dllFile.existsSync() && dllFile.lastModifiedSync().isAfter(buildCompiled.lastModifiedSync())) {
        await buildCompiled.delete();
      }

      await for (final entity in rulesSrc.list()) {
        if (entity is File && (entity.path.endsWith('.yar') || entity.path.endsWith('.yara'))) {
          final targetYar = File(p.join(rulesTarget.path, p.basename(entity.path)));
          final needsCopy = !targetYar.existsSync() || entity.lastModifiedSync().isAfter(targetYar.lastModifiedSync());
          if (needsCopy) {
            await entity.copy(targetYar.path);
            if (buildCompiled.existsSync()) await buildCompiled.delete();
          }
        }
      }

      final communitySrc = Directory(p.join(AppPaths.dataDir, 'yara_rules', 'community'));
      if (communitySrc.existsSync()) {
        final communityTarget = Directory(p.join(rulesTarget.path, 'community'));
        final srcEntries = await communitySrc.list().toList();
        final srcCount = srcEntries.whereType<File>().length;
        final tgtCount = communityTarget.existsSync() ? (await communityTarget.list().toList()).whereType<File>().length : 0;
        if (srcCount != tgtCount) {
          await communityTarget.create(recursive: true);
          for (final entity in srcEntries) {
            if (entity is File) {
              final ruleName = p.basename(entity.path);
              await entity.copy(p.join(communityTarget.path, ruleName));
            }
          }
          if (buildCompiled.existsSync()) await buildCompiled.delete();
        } else if (buildCompiled.existsSync() && communityTarget.existsSync()) {
          final yrcMtime = buildCompiled.lastModifiedSync();
          for (final f in communityTarget.listSync().whereType<File>()) {
            if (f.lastModifiedSync().isAfter(yrcMtime)) {
              await buildCompiled.delete();
              break;
            }
          }
        }
      }
    }
  } catch (_) {  }
}

void _logCrash(String message) {
  try {
    final appData = Platform.environment['APPDATA'] ?? '.';
    final dir = Directory('$appData\\mentoringprotector');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    final file = File('${dir.path}\\crash_log.txt');
    file.writeAsStringSync('${DateTime.now()}\n$message\n\n', mode: FileMode.append);
  } catch (e) {  }
}

class MentoringProtectorApp extends StatelessWidget {
  final DllInitResult initResult;
  const MentoringProtectorApp({super.key, required this.initResult});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();

    return MaterialApp(
      title: 'Mentoring Protector',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: state.themeMode,
      locale: state.flutterLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: switch (initResult) {
        DllInitSuccess() => const _OnboardingGate(),
        DllInitFailure() => DllErrorScreen(reason: (initResult as DllInitFailure).reason),
      },
                      );
  }
}

class _OnboardingGate extends StatelessWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    if (!profileProvider.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!profileProvider.onboardingCompleted) {
      return OnboardingScreen(
        onComplete: (level, goal) {
          profileProvider.completeOnboarding(level: level, goal: goal);
        },
      );
    }
    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with WindowListener {
  int _index = 0;
  Timer? _nudgePollTimer;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _nudgePollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) async {
        if (!mounted) return;
        final nudgeProv = context.read<NudgeProvider>();
        nudgeProv.poll();

        if (nudgeProv.consumeTrayClick() && mounted) {
          await windowManager.show();
          await windowManager.focus();
          final nudge = nudgeProv.consumeBalloonNudge();
          if (nudge != null && mounted) {
            NudgeSheet.show(
              context: context,
              nudge: nudge,
              onScanFile: nudge.category == NudgeCategory.usbDevice
                  ? () => context.read<NudgeProvider>().retriggerUsbScan(nudge)
                  : null,
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _nudgePollTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() => _ensureTitleBarHidden();
  @override
  void onWindowMaximize() => _ensureTitleBarHidden();
  @override
  void onWindowUnmaximize() => _ensureTitleBarHidden();
  @override
  void onWindowRestore() => _ensureTitleBarHidden();

  void _ensureTitleBarHidden() {
    windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  String _screenTitle(dynamic l10n) => switch (_index) { 0 => l10n.homeTitle, 1 => l10n.scanTitle, 2 => l10n.protectionTitle, 3 => l10n.navStats, 4 => l10n.navHygiene, 5 => l10n.settingsTitle, _ => l10n.homeTitle };

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    return Scaffold(
      body: Column(
        children: [
          AppTitleBar(
            title: _screenTitle(l10n),
            colors: colors,
          ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                HomeScreen(
                  onScanPressed: () => setState(() => _index = 1),
                  onOpenStats: () => setState(() => _index = 3),
                ),
                const ScanScreen(),
                const ProtectionScreen(),
                const StatsDashboardScreen(),
                const HygieneScreen(),
                SettingsScreen(
                  onOpenStats: () => setState(() => _index = 3),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 64,
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: colors.surface,
          indicatorColor: colors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 22),
              selectedIcon: const Icon(Icons.home, size: 22),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_outlined, size: 22),
              selectedIcon: const Icon(Icons.search, size: 22),
              label: l10n.navScan,
            ),
            NavigationDestination(
              icon: const Icon(Icons.security_outlined, size: 22),
              selectedIcon: const Icon(Icons.security, size: 22),
              label: l10n.navProtection,
            ),
            NavigationDestination(
              icon: const Icon(Icons.analytics_outlined, size: 22),
              selectedIcon: const Icon(Icons.analytics, size: 22),
              label: l10n.navStats,
            ),
            NavigationDestination(
              icon: const Icon(Icons.health_and_safety_outlined, size: 22),
              selectedIcon: const Icon(Icons.health_and_safety, size: 22),
              label: l10n.navHygiene,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined, size: 22),
              selectedIcon: const Icon(Icons.settings, size: 22),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class DllErrorScreen extends StatelessWidget {
  final String reason;
  const DllErrorScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: 16),
              const Text(
                'Ошибка загрузки DLL',
                style: TextStyle(fontSize: AppTextStyles.sizeHeader, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: AppTextStyles.sizeBody),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

