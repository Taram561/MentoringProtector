
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../../ffi/app_paths.dart';
import '../../providers/app_state_provider.dart';
import '../../models/user_profile.dart';
import '../../l10n/app_localizations.g.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_title_bar.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(UserLevel level, String goal) onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  UserLevel _selectedLevel = UserLevel.regular;
  String _selectedGoal = 'balanced';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete(_selectedLevel, _selectedGoal);
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 52, bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      width: i == _currentPage ? Spacing.xl : Spacing.s,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? colors.primary
                            : colors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _WelcomePage(l10n: l10n, colors: colors),
                      _LevelPage(
                        l10n: l10n,
                        colors: colors,
                        selected: _selectedLevel,
                        onSelect: (v) => setState(() => _selectedLevel = v),
                      ),
                      _GoalPage(
                        l10n: l10n,
                        colors: colors,
                        selected: _selectedGoal,
                        onSelect: (v) => setState(() => _selectedGoal = v),
                      ),
                      _ExtensionPage(
                        l10n: l10n,
                        colors: colors,
                        onSkip: _next,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Spacing.xl, 0, Spacing.xl, Spacing.xl),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _back,
                          child: Text(l10n.onboardingBack),
                        ),
                      const Spacer(),
                      AppButton(
                        label: _currentPage == 3
                            ? l10n.onboardingStart
                            : l10n.onboardingNext,
                        colors: colors,
                        onPressed: _next,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DragToMoveArea(
              child: Container(
                height: 44,
                padding: const EdgeInsets.only(right: Spacing.s),
                child: const Row(
                  children: [
                    Spacer(),
                    WindowControls(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final AppLocalizations l10n;
  final AdaptiveColors colors;

  const _WelcomePage({required this.l10n, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colors.gradientEnd,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(Icons.shield, size: 52, color: colors.onPrimary),
          ),
          const SizedBox(height: Spacing.xxl),
          Text(
            l10n.onboardingWelcome,
            style: TextStyle(
              fontSize: AppTextStyles.sizeLarge,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.m),
          Text(
            l10n.onboardingWelcomeDesc,
            style: TextStyle(
              fontSize: AppTextStyles.sizeLabel,
              color: colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LevelPage extends StatelessWidget {
  final AppLocalizations l10n;
  final AdaptiveColors colors;
  final UserLevel selected;
  final ValueChanged<UserLevel> onSelect;

  const _LevelPage({
    required this.l10n,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.l),
          Text(
            l10n.onboardingLevelTitle,
            style: TextStyle(
              fontSize: AppTextStyles.sizeHeadline,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.onboardingLevelDesc,
            style: TextStyle(
              fontSize: AppTextStyles.sizeBody,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          _OptionTile(
            icon: Icons.school_outlined,
            title: l10n.onboardingBeginner,
            subtitle: l10n.onboardingBeginnerDesc,
            color: colors.success,
            selected: selected == UserLevel.beginner,
            onTap: () => onSelect(UserLevel.beginner),
          ),
          const SizedBox(height: Spacing.m),
          _OptionTile(
            icon: Icons.person_outlined,
            title: l10n.onboardingRegular,
            subtitle: l10n.onboardingRegularDesc,
            color: colors.primary,
            selected: selected == UserLevel.regular,
            onTap: () => onSelect(UserLevel.regular),
          ),
          const SizedBox(height: Spacing.m),
          _OptionTile(
            icon: Icons.code,
            title: l10n.onboardingAdvanced,
            subtitle: l10n.onboardingAdvancedDesc,
            color: colors.accentPurple,
            selected: selected == UserLevel.advanced,
            onTap: () => onSelect(UserLevel.advanced),
          ),
        ],
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final AppLocalizations l10n;
  final AdaptiveColors colors;
  final String selected;
  final ValueChanged<String> onSelect;

  const _GoalPage({
    required this.l10n,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.l),
          Text(
            l10n.onboardingGoalTitle,
            style: TextStyle(
              fontSize: AppTextStyles.sizeHeadline,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.onboardingGoalDesc,
            style: TextStyle(
              fontSize: AppTextStyles.sizeBody,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: Spacing.xl),
          _OptionTile(
            icon: Icons.security,
            title: l10n.onboardingGoalMax,
            subtitle: l10n.onboardingGoalMaxDesc,
            color: colors.danger,
            selected: selected == 'max',
            onTap: () => onSelect('max'),
          ),
          const SizedBox(height: Spacing.m),
          _OptionTile(
            icon: Icons.balance,
            title: l10n.onboardingGoalBalanced,
            subtitle: l10n.onboardingGoalBalancedDesc,
            color: colors.primary,
            selected: selected == 'balanced',
            onTap: () => onSelect('balanced'),
          ),
          const SizedBox(height: Spacing.m),
          _OptionTile(
            icon: Icons.lightbulb_outlined,
            title: l10n.onboardingGoalLearn,
            subtitle: l10n.onboardingGoalLearnDesc,
            color: colors.warning,
            selected: selected == 'learn',
            onTap: () => onSelect('learn'),
          ),
        ],
      ),
    );
  }
}


class _ExtensionPage extends StatefulWidget {
  final AppLocalizations l10n;
  final AdaptiveColors colors;
  final VoidCallback onSkip;

  const _ExtensionPage({
    required this.l10n,
    required this.colors,
    required this.onSkip,
  });

  @override
  State<_ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<_ExtensionPage> {
  bool _checking = false;
  int _checkAttempt = 0;
  bool? _connected;

  Future<void> _startCheck() async {
    if (_checking) return;
    _checking = true;
    for (int i = 1; i <= 3; i++) {
      if (!mounted) { _checking = false; return; }
      setState(() { _checkAttempt = i; _connected = null; });
      try {
        final resp = await http
            .get(Uri.parse('http://localhost:27432/health'))
            .timeout(const Duration(seconds: 1));
        if (resp.statusCode == 200) {
          if (mounted) setState(() { _connected = true; _checkAttempt = 0; });
          _checking = false;
          return;
        }
      } catch (e) { debugPrint('[MP] Onboarding health check: $e'); }
      if (i < 3) await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) setState(() { _connected = false; _checkAttempt = 0; });
    _checking = false;
  }

  void _openFolder() {
    unawaited(Process.run('explorer.exe', [AppPaths.extensionChromeDir]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final colors = widget.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Spacing.l),
          Row(children: [
            Icon(Icons.extension_rounded, color: colors.primary, size: 26),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.onbExtTitle,
                style: TextStyle(fontSize: AppTextStyles.sizeHeadline, fontWeight: FontWeight.w700,
                    color: colors.textPrimary))),
          ]),
          const SizedBox(height: Spacing.xs),
          Text(l10n.onbExtSubtitle,
              style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textSecondary)),
          const SizedBox(height: Spacing.xl),
          _StepRow(n: 1, text: l10n.onbExtStep1, colors: colors),
          const SizedBox(height: Spacing.m),
          _StepRow(n: 2, text: l10n.onbExtStep2, colors: colors),
          const SizedBox(height: Spacing.m),
          _StepRow(n: 3, text: l10n.onbExtStep3, colors: colors),
          const SizedBox(height: Spacing.l),
          OutlinedButton.icon(
            icon: const Icon(Icons.folder_open_rounded, size: 16),
            label: Text(l10n.onbExtOpenFolder),
            onPressed: _openFolder,
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(height: Spacing.l),
          const Divider(height: 1),
          const SizedBox(height: Spacing.m),
          _buildStatus(l10n, colors),
          const SizedBox(height: Spacing.l),
          TextButton(
            onPressed: widget.onSkip,
            child: Text(l10n.onbExtSkip,
                style: TextStyle(color: colors.textSecondary)),
          ),
          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }

  Widget _buildStatus(AppLocalizations l10n, AdaptiveColors colors) {
    if (_checkAttempt > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            color: colors.primary,
            backgroundColor: colors.primary.withValues(alpha: 0.15),
          ),
          const SizedBox(height: Spacing.s),
          Text(l10n.onbExtChecking(_checkAttempt),
              style: TextStyle(fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary)),
        ],
      );
    }
    if (_connected == true) {
      return Row(children: [
        Icon(Icons.check_circle_rounded, color: colors.success, size: 20),
        const SizedBox(width: 8),
        Text(l10n.onbExtConnected,
            style: TextStyle(fontSize: AppTextStyles.sizeBody, fontWeight: FontWeight.w500,
                color: colors.success)),
      ]);
    }
    if (_connected == false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.cancel_rounded, color: colors.danger, size: 20),
            const SizedBox(width: 8),
            Text(l10n.onbExtNotConnected,
                style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.danger)),
          ]),
          const SizedBox(height: Spacing.s),
          TextButton(
            onPressed: _startCheck,
            child: Text(l10n.onbExtCheckConnection,
                style: TextStyle(color: colors.primary)),
          ),
        ],
      );
    }
    return OutlinedButton(
      onPressed: _startCheck,
      style: OutlinedButton.styleFrom(foregroundColor: colors.primary),
      child: Text(l10n.onbExtCheckConnection),
    );
  }
}


class _StepRow extends StatelessWidget {
  final int n;
  final String text;
  final AdaptiveColors colors;

  const _StepRow({required this.n, required this.text, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('$n',
              style: TextStyle(fontSize: AppTextStyles.sizeDefault, fontWeight: FontWeight.w700,
                  color: colors.primary)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: Spacing.xs),
          child: Text(text,
              style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textPrimary,
                  height: 1.4)),
        )),
      ],
    );
  }
}


class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.read<AppStateProvider>().colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(Spacing.l),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : colors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.5)
                : colors.divider.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: selected ? 0.2 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeLabel,
                      fontWeight: FontWeight.w600,
                      color: selected ? color : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

