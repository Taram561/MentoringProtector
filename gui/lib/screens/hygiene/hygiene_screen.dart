
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import 'hygiene_data.dart';
import 'quiz_data.dart';
import 'widgets/hygiene_index_card.dart';
import 'widgets/tip_quiz_sheet.dart';
import '../threat_library/threat_library_screen.dart';

class HygieneScreen extends StatefulWidget {
  final bool showAppBar;
  const HygieneScreen({super.key, this.showAppBar = false});

  @override
  State<HygieneScreen> createState() => _HygieneScreenState();
}

class _HygieneScreenState extends State<HygieneScreen> {
  bool _snapshotSaved = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    final profileProvider = context.watch<UserProfileProvider>();
    final profile = profileProvider.profile;
    final completed = profileProvider.completedTips;
    final userLevel = profile.level;

    if (profileProvider.loaded && !_snapshotSaved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileProvider.resetQuizzesIfMonthPassed();
      });
    }

    final hygieneIndex = computeHygieneIndex(profile, completed);

    if (!_snapshotSaved && profileProvider.loaded) {
      _snapshotSaved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileProvider.snapshotHygieneIndex(hygieneIndex);
      });
    }

    final sorted = List.of(allTips)
      ..sort((a, b) => tipPriority(b.id, profile, completed)
          .compareTo(tipPriority(a.id, profile, completed)));

    final recommended = sorted.where((t) => !completed.contains(t.id.name) && tipPriority(t.id, profile, completed) > 0).take(4).toList();

    final listView = ListView(
      padding: Spacing.screenPadding,
      children: [
        HygieneIndexCard(
          index: hygieneIndex,
          history: profileProvider.hygieneHistory,
          completedCount: completed.length,
          totalCount: allTips.length,
          l10n: l10n,
        ),

        const SizedBox(height: Spacing.l),
        _ThreatLibraryBanner(colors: colors, l10n: l10n),

        if (recommended.isNotEmpty) ...[
          const SizedBox(height: Spacing.xl),
          Text(
            l10n.hygieneWeeklyTitle,
            style: TextStyle(
              fontSize: AppTextStyles.sizeSubtitle,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.hygieneWeeklySubtitle,
            style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
          ),
          const SizedBox(height: Spacing.s),
          ...recommended.map((tip) => _RecommendedTipCard(
                tip: tip,
                reason: tipReasonText(tip.id, profile, l10n),
                colors: colors,
                l10n: l10n,
                userLevel: userLevel,
                onQuiz: () => _openQuiz(context, tip.id, l10n, profileProvider),
              )),
        ],

        const SizedBox(height: Spacing.xl),
        Text(
          l10n.hygieneAllTips,
          style: TextStyle(
            fontSize: AppTextStyles.sizeSubtitle,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: Spacing.s),
        ...sorted.map((tip) {
          final isDone = completed.contains(tip.id.name);
          final quizResult = profileProvider.quizResults[tip.id.name];
          return _TipCard(
            tip: tip,
            isDone: isDone,
            quizResult: quizResult,
            colors: colors,
            l10n: l10n,
            userLevel: userLevel,
            onQuiz: () => _openQuiz(context, tip.id, l10n, profileProvider),
          );
        }),
      ],
    );
    if (widget.showAppBar) {
      return AppTitleBarScaffold(
        title: l10n.helpQuizTitle,
        colors: colors,
        body: listView,
      );
    }
    return Scaffold(
      backgroundColor: colors.background,
      body: listView,
    );
  }

  void _openQuiz(BuildContext ctx, HygieneTipId tipId,
      dynamic l10n, UserProfileProvider provider) {
    final quiz = allQuizzes[tipId];
    if (quiz == null) return;

    showQuizDialog(
      context: ctx,
      quiz: quiz,
      l10n: l10n,
      seenIndices: provider.getSeenQuestions(tipId.name),
      onCompleted: (correct, total, shownIndices) {
        provider.markQuestionsShown(
            tipId.name, shownIndices, quiz.questions.length);
        provider.markTipCompleted(tipId.name);
        provider.saveQuizResult(tipId.name, correct, total);

        if (correct == total) {
          provider.recordEvent(RiskEventType.lessonCompleted,
              detail: 'quiz:${tipId.name}:perfect');
        } else {
          final wrongCount = total - correct;
          provider.recordEvent(RiskEventType.quizWrongAnswer,
              detail: 'quiz:${tipId.name}:wrong:$wrongCount');
        }
      },
    );
  }
}


class _ThreatLibraryBanner extends StatelessWidget {
  final dynamic colors;
  final dynamic l10n;
  const _ThreatLibraryBanner({required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final c = colors as AdaptiveColors;
    return AppCard(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ThreatLibraryScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.local_library_outlined,
                  color: c.primary, size: 24),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.threatLibraryTitle as String,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeBody,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.threatLibraryDesc as String,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}


class _RecommendedTipCard extends StatelessWidget {
  final HygieneTipData tip;
  final String? reason;
  final dynamic colors;
  final dynamic l10n;
  final UserLevel userLevel;
  final VoidCallback onQuiz;

  const _RecommendedTipCard({
    required this.tip,
    required this.reason,
    required this.colors,
    required this.l10n,
    required this.userLevel,
    required this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final tipColor = tip.color(colors);

    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.s),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: tipColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: tipColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tip.icon, color: tipColor, size: 22),
                ),
                const SizedBox(width: Spacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.s - 2, vertical: 2),
                        decoration: BoxDecoration(
                          color: tipColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.hygieneRecommended,
                          style: TextStyle(
                            fontSize: AppTextStyles.sizeTiny,
                            fontWeight: FontWeight.w600,
                            color: tipColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        tip.title(l10n),
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeLabel,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.s),
            Text(
              tip.adaptiveDescription(l10n, userLevel),
              style: TextStyle(
                fontSize: AppTextStyles.sizeDefault,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
            if (reason != null) ...[
              const SizedBox(height: Spacing.xs + 2),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: tipColor),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      reason!,
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeXSmall,
                        fontStyle: FontStyle.italic,
                        color: tipColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Spacing.s),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onQuiz,
                icon: const Icon(Icons.quiz_outlined, size: 16),
                label: Text(l10n.quizTakeQuiz),
                style: FilledButton.styleFrom(
                  backgroundColor: tipColor,
                  foregroundColor: (colors as AdaptiveColors).onPrimary,
                  textStyle: const TextStyle(fontSize: AppTextStyles.sizeDefault),
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.l, vertical: Spacing.s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _TipCard extends StatelessWidget {
  final HygieneTipData tip;
  final bool isDone;
  final QuizResult? quizResult;
  final dynamic colors;
  final dynamic l10n;
  final UserLevel userLevel;
  final VoidCallback onQuiz;

  const _TipCard({
    required this.tip,
    required this.isDone,
    required this.quizResult,
    required this.colors,
    required this.l10n,
    required this.userLevel,
    required this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final tipColor = tip.color(colors);

    return AppCard(
      onTap: onQuiz,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isDone
                    ? tipColor.withValues(alpha: 0.06)
                    : tipColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                tip.icon,
                color: isDone
                    ? tipColor.withValues(alpha: 0.4)
                    : tipColor,
                size: 22,
              ),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title(l10n),
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeBody,
                      fontWeight: FontWeight.w600,
                      color: isDone
                          ? colors.textPrimary.withValues(alpha: 0.5)
                          : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    tip.adaptiveDescription(l10n, userLevel),
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      color: isDone
                          ? colors.textSecondary.withValues(alpha: 0.5)
                          : colors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs + 2),
                  if (isDone)
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: colors.success),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          l10n.quizPassed,
                          style: TextStyle(
                            fontSize: AppTextStyles.sizeXSmall,
                            fontWeight: FontWeight.w500,
                            color: colors.success,
                          ),
                        ),
                        if (quizResult != null) ...[
                          const SizedBox(width: Spacing.s),
                          _QuizScoreBadge(result: quizResult!, colors: colors),
                        ],
                        const SizedBox(width: Spacing.m),
                        GestureDetector(
                          onTap: onQuiz,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, size: 13,
                                  color: colors.primary),
                              const SizedBox(width: 3),
                              Text(
                                l10n.quizRetake,
                                style: TextStyle(
                                  fontSize: AppTextStyles.sizeXSmall,
                                  color: colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz_outlined, size: 13,
                            color: colors.primary),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          l10n.quizTakeQuiz,
                          style: TextStyle(
                            fontSize: AppTextStyles.sizeXSmall,
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Spacing.s),
              child: Icon(
                isDone ? Icons.check_circle : Icons.quiz_outlined,
                size: 22,
                color: isDone
                    ? colors.success
                    : colors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _QuizScoreBadge extends StatelessWidget {
  final QuizResult result;
  final dynamic colors;
  const _QuizScoreBadge({required this.result, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = result.isPerfect
        ? colors.success as Color
        : result.ratio >= 0.6
            ? colors.warning as Color
            : colors.danger as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs + 2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            result.isPerfect ? Icons.star : Icons.score_outlined,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${result.correct}/${result.total}',
            style: TextStyle(
              fontSize: AppTextStyles.sizeTiny,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

