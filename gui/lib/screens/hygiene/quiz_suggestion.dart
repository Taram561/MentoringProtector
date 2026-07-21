
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_profile_provider.dart';
import '../../l10n/app_localizations.g.dart';
import 'hygiene_data.dart';
import 'quiz_data.dart';
import 'widgets/tip_quiz_sheet.dart';

const _eventToTip = <RiskEventType, HygieneTipId>{ RiskEventType.webWarningIgnored: HygieneTipId.phishing, RiskEventType.scanThreatIgnored: HygieneTipId.backup, RiskEventType.dangerousDownload: HygieneTipId.downloads, RiskEventType.protectionDisabled: HygieneTipId.update };

void suggestQuizForEvent(BuildContext context, RiskEventType eventType) {
  final tipId = _eventToTip[eventType];
  if (tipId == null) return;

  final quiz = allQuizzes[tipId];
  if (quiz == null) return;

  final state = context.read<AppStateProvider>();
  final l10n = state.strings;
  final profileProvider = context.read<UserProfileProvider>();

  if (profileProvider.completedTips.contains(tipId.name)) return;

  final message = _suggestionMessage(eventType, l10n);
  if (message == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.school_outlined, color: AppColors.onPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: l10n.quizSuggestionAction,
        textColor: AppColors.warning,
        onPressed: () {
          _openSuggestedQuiz(context, tipId, l10n, profileProvider);
        },
      ),
    ),
  );
}

String? _suggestionMessage(RiskEventType type, AppLocalizations l10n) {
  return switch (type) { RiskEventType.webWarningIgnored => l10n.quizSuggestionWeb, RiskEventType.scanThreatIgnored => l10n.quizSuggestionScan, RiskEventType.dangerousDownload => l10n.quizSuggestionDownload, RiskEventType.protectionDisabled => l10n.quizSuggestionProtection, _ => null };
}

void _openSuggestedQuiz(BuildContext context, HygieneTipId tipId, AppLocalizations l10n, UserProfileProvider provider) {
  final quiz = allQuizzes[tipId];
  if (quiz == null) return;

  showQuizDialog(
    context: context,
    quiz: quiz,
    l10n: l10n,
    seenIndices: provider.getSeenQuestions(tipId.name),
    onCompleted: (correct, total, shownIndices) {
      provider.markQuestionsShown(tipId.name, shownIndices, quiz.questions.length);
      provider.markTipCompleted(tipId.name);
      provider.saveQuizResult(tipId.name, correct, total);

      if (correct == total) {
        provider.recordEvent(RiskEventType.lessonCompleted, detail: 'quiz:${tipId.name}:perfect:suggested');
      } else {
        final wrongCount = total - correct;
        provider.recordEvent(RiskEventType.quizWrongAnswer, detail: 'quiz:${tipId.name}:wrong:$wrongCount:suggested');
      }
    },
  );
}

