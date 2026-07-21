
import '../../l10n/app_localizations.g.dart';
import 'hygiene_data.dart';

class QuizQuestion {
  final String Function(AppLocalizations) question;
  final List<String Function(AppLocalizations)> options;
  final String Function(AppLocalizations) explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.explanation,
  });
}

class TipQuiz {
  final HygieneTipId tipId;
  final List<QuizQuestion> questions;
  const TipQuiz({required this.tipId, required this.questions});
}

final allQuizzes = <HygieneTipId, TipQuiz>{

  HygieneTipId.update: TipQuiz(tipId: HygieneTipId.update, questions: [
    QuizQuestion(
      question: (l) => l.quizUpdateQ1,
      options: [(l) => l.quizUpdateQ1A1, (l) => l.quizUpdateQ1A2,
                (l) => l.quizUpdateQ1A3, (l) => l.quizUpdateQ1A4],
      explanation: (l) => l.quizUpdateQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ2,
      options: [(l) => l.quizUpdateQ2A1, (l) => l.quizUpdateQ2A2,
                (l) => l.quizUpdateQ2A3, (l) => l.quizUpdateQ2A4],
      explanation: (l) => l.quizUpdateQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ3,
      options: [(l) => l.quizUpdateQ3A1, (l) => l.quizUpdateQ3A2,
                (l) => l.quizUpdateQ3A3, (l) => l.quizUpdateQ3A4],
      explanation: (l) => l.quizUpdateQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ4,
      options: [(l) => l.quizUpdateQ4A1, (l) => l.quizUpdateQ4A2,
                (l) => l.quizUpdateQ4A3, (l) => l.quizUpdateQ4A4],
      explanation: (l) => l.quizUpdateQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ5,
      options: [(l) => l.quizUpdateQ5A1, (l) => l.quizUpdateQ5A2,
                (l) => l.quizUpdateQ5A3, (l) => l.quizUpdateQ5A4],
      explanation: (l) => l.quizUpdateQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ6,
      options: [(l) => l.quizUpdateQ6A1, (l) => l.quizUpdateQ6A2,
                (l) => l.quizUpdateQ6A3, (l) => l.quizUpdateQ6A4],
      explanation: (l) => l.quizUpdateQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ7,
      options: [(l) => l.quizUpdateQ7A1, (l) => l.quizUpdateQ7A2,
                (l) => l.quizUpdateQ7A3, (l) => l.quizUpdateQ7A4],
      explanation: (l) => l.quizUpdateQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ8,
      options: [(l) => l.quizUpdateQ8A1, (l) => l.quizUpdateQ8A2,
                (l) => l.quizUpdateQ8A3, (l) => l.quizUpdateQ8A4],
      explanation: (l) => l.quizUpdateQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ9,
      options: [(l) => l.quizUpdateQ9A1, (l) => l.quizUpdateQ9A2,
                (l) => l.quizUpdateQ9A3, (l) => l.quizUpdateQ9A4],
      explanation: (l) => l.quizUpdateQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUpdateQ10,
      options: [(l) => l.quizUpdateQ10A1, (l) => l.quizUpdateQ10A2,
                (l) => l.quizUpdateQ10A3, (l) => l.quizUpdateQ10A4],
      explanation: (l) => l.quizUpdateQ10Explain,
    ),
  ]),

  HygieneTipId.passwords: TipQuiz(tipId: HygieneTipId.passwords, questions: [
    QuizQuestion(
      question: (l) => l.quizPasswordQ1,
      options: [(l) => l.quizPasswordQ1A1, (l) => l.quizPasswordQ1A2,
                (l) => l.quizPasswordQ1A3, (l) => l.quizPasswordQ1A4],
      explanation: (l) => l.quizPasswordQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ2,
      options: [(l) => l.quizPasswordQ2A1, (l) => l.quizPasswordQ2A2,
                (l) => l.quizPasswordQ2A3, (l) => l.quizPasswordQ2A4],
      explanation: (l) => l.quizPasswordQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ3,
      options: [(l) => l.quizPasswordQ3A1, (l) => l.quizPasswordQ3A2,
                (l) => l.quizPasswordQ3A3, (l) => l.quizPasswordQ3A4],
      explanation: (l) => l.quizPasswordQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ4,
      options: [(l) => l.quizPasswordQ4A1, (l) => l.quizPasswordQ4A2,
                (l) => l.quizPasswordQ4A3, (l) => l.quizPasswordQ4A4],
      explanation: (l) => l.quizPasswordQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ5,
      options: [(l) => l.quizPasswordQ5A1, (l) => l.quizPasswordQ5A2,
                (l) => l.quizPasswordQ5A3, (l) => l.quizPasswordQ5A4],
      explanation: (l) => l.quizPasswordQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ6,
      options: [(l) => l.quizPasswordQ6A1, (l) => l.quizPasswordQ6A2,
                (l) => l.quizPasswordQ6A3, (l) => l.quizPasswordQ6A4],
      explanation: (l) => l.quizPasswordQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ7,
      options: [(l) => l.quizPasswordQ7A1, (l) => l.quizPasswordQ7A2,
                (l) => l.quizPasswordQ7A3, (l) => l.quizPasswordQ7A4],
      explanation: (l) => l.quizPasswordQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ8,
      options: [(l) => l.quizPasswordQ8A1, (l) => l.quizPasswordQ8A2,
                (l) => l.quizPasswordQ8A3, (l) => l.quizPasswordQ8A4],
      explanation: (l) => l.quizPasswordQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ9,
      options: [(l) => l.quizPasswordQ9A1, (l) => l.quizPasswordQ9A2,
                (l) => l.quizPasswordQ9A3, (l) => l.quizPasswordQ9A4],
      explanation: (l) => l.quizPasswordQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPasswordQ10,
      options: [(l) => l.quizPasswordQ10A1, (l) => l.quizPasswordQ10A2,
                (l) => l.quizPasswordQ10A3, (l) => l.quizPasswordQ10A4],
      explanation: (l) => l.quizPasswordQ10Explain,
    ),
  ]),

  HygieneTipId.wifi: TipQuiz(tipId: HygieneTipId.wifi, questions: [
    QuizQuestion(
      question: (l) => l.quizWifiQ1,
      options: [(l) => l.quizWifiQ1A1, (l) => l.quizWifiQ1A2,
                (l) => l.quizWifiQ1A3, (l) => l.quizWifiQ1A4],
      explanation: (l) => l.quizWifiQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ2,
      options: [(l) => l.quizWifiQ2A1, (l) => l.quizWifiQ2A2,
                (l) => l.quizWifiQ2A3, (l) => l.quizWifiQ2A4],
      explanation: (l) => l.quizWifiQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ3,
      options: [(l) => l.quizWifiQ3A1, (l) => l.quizWifiQ3A2,
                (l) => l.quizWifiQ3A3, (l) => l.quizWifiQ3A4],
      explanation: (l) => l.quizWifiQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ4,
      options: [(l) => l.quizWifiQ4A1, (l) => l.quizWifiQ4A2,
                (l) => l.quizWifiQ4A3, (l) => l.quizWifiQ4A4],
      explanation: (l) => l.quizWifiQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ5,
      options: [(l) => l.quizWifiQ5A1, (l) => l.quizWifiQ5A2,
                (l) => l.quizWifiQ5A3, (l) => l.quizWifiQ5A4],
      explanation: (l) => l.quizWifiQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ6,
      options: [(l) => l.quizWifiQ6A1, (l) => l.quizWifiQ6A2,
                (l) => l.quizWifiQ6A3, (l) => l.quizWifiQ6A4],
      explanation: (l) => l.quizWifiQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ7,
      options: [(l) => l.quizWifiQ7A1, (l) => l.quizWifiQ7A2,
                (l) => l.quizWifiQ7A3, (l) => l.quizWifiQ7A4],
      explanation: (l) => l.quizWifiQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ8,
      options: [(l) => l.quizWifiQ8A1, (l) => l.quizWifiQ8A2,
                (l) => l.quizWifiQ8A3, (l) => l.quizWifiQ8A4],
      explanation: (l) => l.quizWifiQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ9,
      options: [(l) => l.quizWifiQ9A1, (l) => l.quizWifiQ9A2,
                (l) => l.quizWifiQ9A3, (l) => l.quizWifiQ9A4],
      explanation: (l) => l.quizWifiQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizWifiQ10,
      options: [(l) => l.quizWifiQ10A1, (l) => l.quizWifiQ10A2,
                (l) => l.quizWifiQ10A3, (l) => l.quizWifiQ10A4],
      explanation: (l) => l.quizWifiQ10Explain,
    ),
  ]),

  HygieneTipId.phishing: TipQuiz(tipId: HygieneTipId.phishing, questions: [
    QuizQuestion(
      question: (l) => l.quizPhishingQ1,
      options: [(l) => l.quizPhishingQ1A1, (l) => l.quizPhishingQ1A2,
                (l) => l.quizPhishingQ1A3, (l) => l.quizPhishingQ1A4],
      explanation: (l) => l.quizPhishingQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ2,
      options: [(l) => l.quizPhishingQ2A1, (l) => l.quizPhishingQ2A2,
                (l) => l.quizPhishingQ2A3, (l) => l.quizPhishingQ2A4],
      explanation: (l) => l.quizPhishingQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ3,
      options: [(l) => l.quizPhishingQ3A1, (l) => l.quizPhishingQ3A2,
                (l) => l.quizPhishingQ3A3, (l) => l.quizPhishingQ3A4],
      explanation: (l) => l.quizPhishingQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ4,
      options: [(l) => l.quizPhishingQ4A1, (l) => l.quizPhishingQ4A2,
                (l) => l.quizPhishingQ4A3, (l) => l.quizPhishingQ4A4],
      explanation: (l) => l.quizPhishingQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ5,
      options: [(l) => l.quizPhishingQ5A1, (l) => l.quizPhishingQ5A2,
                (l) => l.quizPhishingQ5A3, (l) => l.quizPhishingQ5A4],
      explanation: (l) => l.quizPhishingQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ6,
      options: [(l) => l.quizPhishingQ6A1, (l) => l.quizPhishingQ6A2,
                (l) => l.quizPhishingQ6A3, (l) => l.quizPhishingQ6A4],
      explanation: (l) => l.quizPhishingQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ7,
      options: [(l) => l.quizPhishingQ7A1, (l) => l.quizPhishingQ7A2,
                (l) => l.quizPhishingQ7A3, (l) => l.quizPhishingQ7A4],
      explanation: (l) => l.quizPhishingQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ8,
      options: [(l) => l.quizPhishingQ8A1, (l) => l.quizPhishingQ8A2,
                (l) => l.quizPhishingQ8A3, (l) => l.quizPhishingQ8A4],
      explanation: (l) => l.quizPhishingQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ9,
      options: [(l) => l.quizPhishingQ9A1, (l) => l.quizPhishingQ9A2,
                (l) => l.quizPhishingQ9A3, (l) => l.quizPhishingQ9A4],
      explanation: (l) => l.quizPhishingQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPhishingQ10,
      options: [(l) => l.quizPhishingQ10A1, (l) => l.quizPhishingQ10A2,
                (l) => l.quizPhishingQ10A3, (l) => l.quizPhishingQ10A4],
      explanation: (l) => l.quizPhishingQ10Explain,
    ),
  ]),

  HygieneTipId.backup: TipQuiz(tipId: HygieneTipId.backup, questions: [
    QuizQuestion(
      question: (l) => l.quizBackupQ1,
      options: [(l) => l.quizBackupQ1A1, (l) => l.quizBackupQ1A2,
                (l) => l.quizBackupQ1A3, (l) => l.quizBackupQ1A4],
      explanation: (l) => l.quizBackupQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ2,
      options: [(l) => l.quizBackupQ2A1, (l) => l.quizBackupQ2A2,
                (l) => l.quizBackupQ2A3, (l) => l.quizBackupQ2A4],
      explanation: (l) => l.quizBackupQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ3,
      options: [(l) => l.quizBackupQ3A1, (l) => l.quizBackupQ3A2,
                (l) => l.quizBackupQ3A3, (l) => l.quizBackupQ3A4],
      explanation: (l) => l.quizBackupQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ4,
      options: [(l) => l.quizBackupQ4A1, (l) => l.quizBackupQ4A2,
                (l) => l.quizBackupQ4A3, (l) => l.quizBackupQ4A4],
      explanation: (l) => l.quizBackupQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ5,
      options: [(l) => l.quizBackupQ5A1, (l) => l.quizBackupQ5A2,
                (l) => l.quizBackupQ5A3, (l) => l.quizBackupQ5A4],
      explanation: (l) => l.quizBackupQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ6,
      options: [(l) => l.quizBackupQ6A1, (l) => l.quizBackupQ6A2,
                (l) => l.quizBackupQ6A3, (l) => l.quizBackupQ6A4],
      explanation: (l) => l.quizBackupQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ7,
      options: [(l) => l.quizBackupQ7A1, (l) => l.quizBackupQ7A2,
                (l) => l.quizBackupQ7A3, (l) => l.quizBackupQ7A4],
      explanation: (l) => l.quizBackupQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ8,
      options: [(l) => l.quizBackupQ8A1, (l) => l.quizBackupQ8A2,
                (l) => l.quizBackupQ8A3, (l) => l.quizBackupQ8A4],
      explanation: (l) => l.quizBackupQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ9,
      options: [(l) => l.quizBackupQ9A1, (l) => l.quizBackupQ9A2,
                (l) => l.quizBackupQ9A3, (l) => l.quizBackupQ9A4],
      explanation: (l) => l.quizBackupQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizBackupQ10,
      options: [(l) => l.quizBackupQ10A1, (l) => l.quizBackupQ10A2,
                (l) => l.quizBackupQ10A3, (l) => l.quizBackupQ10A4],
      explanation: (l) => l.quizBackupQ10Explain,
    ),
  ]),

  HygieneTipId.downloads: TipQuiz(tipId: HygieneTipId.downloads, questions: [
    QuizQuestion(
      question: (l) => l.quizDownloadQ1,
      options: [(l) => l.quizDownloadQ1A1, (l) => l.quizDownloadQ1A2,
                (l) => l.quizDownloadQ1A3, (l) => l.quizDownloadQ1A4],
      explanation: (l) => l.quizDownloadQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ2,
      options: [(l) => l.quizDownloadQ2A1, (l) => l.quizDownloadQ2A2,
                (l) => l.quizDownloadQ2A3, (l) => l.quizDownloadQ2A4],
      explanation: (l) => l.quizDownloadQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ3,
      options: [(l) => l.quizDownloadQ3A1, (l) => l.quizDownloadQ3A2,
                (l) => l.quizDownloadQ3A3, (l) => l.quizDownloadQ3A4],
      explanation: (l) => l.quizDownloadQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ4,
      options: [(l) => l.quizDownloadQ4A1, (l) => l.quizDownloadQ4A2,
                (l) => l.quizDownloadQ4A3, (l) => l.quizDownloadQ4A4],
      explanation: (l) => l.quizDownloadQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ5,
      options: [(l) => l.quizDownloadQ5A1, (l) => l.quizDownloadQ5A2,
                (l) => l.quizDownloadQ5A3, (l) => l.quizDownloadQ5A4],
      explanation: (l) => l.quizDownloadQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ6,
      options: [(l) => l.quizDownloadQ6A1, (l) => l.quizDownloadQ6A2,
                (l) => l.quizDownloadQ6A3, (l) => l.quizDownloadQ6A4],
      explanation: (l) => l.quizDownloadQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ7,
      options: [(l) => l.quizDownloadQ7A1, (l) => l.quizDownloadQ7A2,
                (l) => l.quizDownloadQ7A3, (l) => l.quizDownloadQ7A4],
      explanation: (l) => l.quizDownloadQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ8,
      options: [(l) => l.quizDownloadQ8A1, (l) => l.quizDownloadQ8A2,
                (l) => l.quizDownloadQ8A3, (l) => l.quizDownloadQ8A4],
      explanation: (l) => l.quizDownloadQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ9,
      options: [(l) => l.quizDownloadQ9A1, (l) => l.quizDownloadQ9A2,
                (l) => l.quizDownloadQ9A3, (l) => l.quizDownloadQ9A4],
      explanation: (l) => l.quizDownloadQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizDownloadQ10,
      options: [(l) => l.quizDownloadQ10A1, (l) => l.quizDownloadQ10A2,
                (l) => l.quizDownloadQ10A3, (l) => l.quizDownloadQ10A4],
      explanation: (l) => l.quizDownloadQ10Explain,
    ),
  ]),

  HygieneTipId.twoFactor: TipQuiz(tipId: HygieneTipId.twoFactor, questions: [
    QuizQuestion(
      question: (l) => l.quiz2faQ1,
      options: [(l) => l.quiz2faQ1A1, (l) => l.quiz2faQ1A2,
                (l) => l.quiz2faQ1A3, (l) => l.quiz2faQ1A4],
      explanation: (l) => l.quiz2faQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ2,
      options: [(l) => l.quiz2faQ2A1, (l) => l.quiz2faQ2A2,
                (l) => l.quiz2faQ2A3, (l) => l.quiz2faQ2A4],
      explanation: (l) => l.quiz2faQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ3,
      options: [(l) => l.quiz2faQ3A1, (l) => l.quiz2faQ3A2,
                (l) => l.quiz2faQ3A3, (l) => l.quiz2faQ3A4],
      explanation: (l) => l.quiz2faQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ4,
      options: [(l) => l.quiz2faQ4A1, (l) => l.quiz2faQ4A2,
                (l) => l.quiz2faQ4A3, (l) => l.quiz2faQ4A4],
      explanation: (l) => l.quiz2faQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ5,
      options: [(l) => l.quiz2faQ5A1, (l) => l.quiz2faQ5A2,
                (l) => l.quiz2faQ5A3, (l) => l.quiz2faQ5A4],
      explanation: (l) => l.quiz2faQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ6,
      options: [(l) => l.quiz2faQ6A1, (l) => l.quiz2faQ6A2,
                (l) => l.quiz2faQ6A3, (l) => l.quiz2faQ6A4],
      explanation: (l) => l.quiz2faQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ7,
      options: [(l) => l.quiz2faQ7A1, (l) => l.quiz2faQ7A2,
                (l) => l.quiz2faQ7A3, (l) => l.quiz2faQ7A4],
      explanation: (l) => l.quiz2faQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ8,
      options: [(l) => l.quiz2faQ8A1, (l) => l.quiz2faQ8A2,
                (l) => l.quiz2faQ8A3, (l) => l.quiz2faQ8A4],
      explanation: (l) => l.quiz2faQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ9,
      options: [(l) => l.quiz2faQ9A1, (l) => l.quiz2faQ9A2,
                (l) => l.quiz2faQ9A3, (l) => l.quiz2faQ9A4],
      explanation: (l) => l.quiz2faQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quiz2faQ10,
      options: [(l) => l.quiz2faQ10A1, (l) => l.quiz2faQ10A2,
                (l) => l.quiz2faQ10A3, (l) => l.quiz2faQ10A4],
      explanation: (l) => l.quiz2faQ10Explain,
    ),
  ]),

  HygieneTipId.usb: TipQuiz(tipId: HygieneTipId.usb, questions: [
    QuizQuestion(
      question: (l) => l.quizUsbQ1,
      options: [(l) => l.quizUsbQ1A1, (l) => l.quizUsbQ1A2,
                (l) => l.quizUsbQ1A3, (l) => l.quizUsbQ1A4],
      explanation: (l) => l.quizUsbQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ2,
      options: [(l) => l.quizUsbQ2A1, (l) => l.quizUsbQ2A2,
                (l) => l.quizUsbQ2A3, (l) => l.quizUsbQ2A4],
      explanation: (l) => l.quizUsbQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ3,
      options: [(l) => l.quizUsbQ3A1, (l) => l.quizUsbQ3A2,
                (l) => l.quizUsbQ3A3, (l) => l.quizUsbQ3A4],
      explanation: (l) => l.quizUsbQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ4,
      options: [(l) => l.quizUsbQ4A1, (l) => l.quizUsbQ4A2,
                (l) => l.quizUsbQ4A3, (l) => l.quizUsbQ4A4],
      explanation: (l) => l.quizUsbQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ5,
      options: [(l) => l.quizUsbQ5A1, (l) => l.quizUsbQ5A2,
                (l) => l.quizUsbQ5A3, (l) => l.quizUsbQ5A4],
      explanation: (l) => l.quizUsbQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ6,
      options: [(l) => l.quizUsbQ6A1, (l) => l.quizUsbQ6A2,
                (l) => l.quizUsbQ6A3, (l) => l.quizUsbQ6A4],
      explanation: (l) => l.quizUsbQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ7,
      options: [(l) => l.quizUsbQ7A1, (l) => l.quizUsbQ7A2,
                (l) => l.quizUsbQ7A3, (l) => l.quizUsbQ7A4],
      explanation: (l) => l.quizUsbQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ8,
      options: [(l) => l.quizUsbQ8A1, (l) => l.quizUsbQ8A2,
                (l) => l.quizUsbQ8A3, (l) => l.quizUsbQ8A4],
      explanation: (l) => l.quizUsbQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ9,
      options: [(l) => l.quizUsbQ9A1, (l) => l.quizUsbQ9A2,
                (l) => l.quizUsbQ9A3, (l) => l.quizUsbQ9A4],
      explanation: (l) => l.quizUsbQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizUsbQ10,
      options: [(l) => l.quizUsbQ10A1, (l) => l.quizUsbQ10A2,
                (l) => l.quizUsbQ10A3, (l) => l.quizUsbQ10A4],
      explanation: (l) => l.quizUsbQ10Explain,
    ),
  ]),

  HygieneTipId.privacy: TipQuiz(tipId: HygieneTipId.privacy, questions: [
    QuizQuestion(
      question: (l) => l.quizPrivacyQ1,
      options: [(l) => l.quizPrivacyQ1A1, (l) => l.quizPrivacyQ1A2,
                (l) => l.quizPrivacyQ1A3, (l) => l.quizPrivacyQ1A4],
      explanation: (l) => l.quizPrivacyQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ2,
      options: [(l) => l.quizPrivacyQ2A1, (l) => l.quizPrivacyQ2A2,
                (l) => l.quizPrivacyQ2A3, (l) => l.quizPrivacyQ2A4],
      explanation: (l) => l.quizPrivacyQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ3,
      options: [(l) => l.quizPrivacyQ3A1, (l) => l.quizPrivacyQ3A2,
                (l) => l.quizPrivacyQ3A3, (l) => l.quizPrivacyQ3A4],
      explanation: (l) => l.quizPrivacyQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ4,
      options: [(l) => l.quizPrivacyQ4A1, (l) => l.quizPrivacyQ4A2,
                (l) => l.quizPrivacyQ4A3, (l) => l.quizPrivacyQ4A4],
      explanation: (l) => l.quizPrivacyQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ5,
      options: [(l) => l.quizPrivacyQ5A1, (l) => l.quizPrivacyQ5A2,
                (l) => l.quizPrivacyQ5A3, (l) => l.quizPrivacyQ5A4],
      explanation: (l) => l.quizPrivacyQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ6,
      options: [(l) => l.quizPrivacyQ6A1, (l) => l.quizPrivacyQ6A2,
                (l) => l.quizPrivacyQ6A3, (l) => l.quizPrivacyQ6A4],
      explanation: (l) => l.quizPrivacyQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ7,
      options: [(l) => l.quizPrivacyQ7A1, (l) => l.quizPrivacyQ7A2,
                (l) => l.quizPrivacyQ7A3, (l) => l.quizPrivacyQ7A4],
      explanation: (l) => l.quizPrivacyQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ8,
      options: [(l) => l.quizPrivacyQ8A1, (l) => l.quizPrivacyQ8A2,
                (l) => l.quizPrivacyQ8A3, (l) => l.quizPrivacyQ8A4],
      explanation: (l) => l.quizPrivacyQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ9,
      options: [(l) => l.quizPrivacyQ9A1, (l) => l.quizPrivacyQ9A2,
                (l) => l.quizPrivacyQ9A3, (l) => l.quizPrivacyQ9A4],
      explanation: (l) => l.quizPrivacyQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizPrivacyQ10,
      options: [(l) => l.quizPrivacyQ10A1, (l) => l.quizPrivacyQ10A2,
                (l) => l.quizPrivacyQ10A3, (l) => l.quizPrivacyQ10A4],
      explanation: (l) => l.quizPrivacyQ10Explain,
    ),
  ]),

  HygieneTipId.lock: TipQuiz(tipId: HygieneTipId.lock, questions: [
    QuizQuestion(
      question: (l) => l.quizLockQ1,
      options: [(l) => l.quizLockQ1A1, (l) => l.quizLockQ1A2,
                (l) => l.quizLockQ1A3, (l) => l.quizLockQ1A4],
      explanation: (l) => l.quizLockQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ2,
      options: [(l) => l.quizLockQ2A1, (l) => l.quizLockQ2A2,
                (l) => l.quizLockQ2A3, (l) => l.quizLockQ2A4],
      explanation: (l) => l.quizLockQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ3,
      options: [(l) => l.quizLockQ3A1, (l) => l.quizLockQ3A2,
                (l) => l.quizLockQ3A3, (l) => l.quizLockQ3A4],
      explanation: (l) => l.quizLockQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ4,
      options: [(l) => l.quizLockQ4A1, (l) => l.quizLockQ4A2,
                (l) => l.quizLockQ4A3, (l) => l.quizLockQ4A4],
      explanation: (l) => l.quizLockQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ5,
      options: [(l) => l.quizLockQ5A1, (l) => l.quizLockQ5A2,
                (l) => l.quizLockQ5A3, (l) => l.quizLockQ5A4],
      explanation: (l) => l.quizLockQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ6,
      options: [(l) => l.quizLockQ6A1, (l) => l.quizLockQ6A2,
                (l) => l.quizLockQ6A3, (l) => l.quizLockQ6A4],
      explanation: (l) => l.quizLockQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ7,
      options: [(l) => l.quizLockQ7A1, (l) => l.quizLockQ7A2,
                (l) => l.quizLockQ7A3, (l) => l.quizLockQ7A4],
      explanation: (l) => l.quizLockQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ8,
      options: [(l) => l.quizLockQ8A1, (l) => l.quizLockQ8A2,
                (l) => l.quizLockQ8A3, (l) => l.quizLockQ8A4],
      explanation: (l) => l.quizLockQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ9,
      options: [(l) => l.quizLockQ9A1, (l) => l.quizLockQ9A2,
                (l) => l.quizLockQ9A3, (l) => l.quizLockQ9A4],
      explanation: (l) => l.quizLockQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizLockQ10,
      options: [(l) => l.quizLockQ10A1, (l) => l.quizLockQ10A2,
                (l) => l.quizLockQ10A3, (l) => l.quizLockQ10A4],
      explanation: (l) => l.quizLockQ10Explain,
    ),
  ]),

  HygieneTipId.extensions: TipQuiz(tipId: HygieneTipId.extensions, questions: [
    QuizQuestion(
      question: (l) => l.quizExtQ1,
      options: [(l) => l.quizExtQ1A1, (l) => l.quizExtQ1A2,
                (l) => l.quizExtQ1A3, (l) => l.quizExtQ1A4],
      explanation: (l) => l.quizExtQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ2,
      options: [(l) => l.quizExtQ2A1, (l) => l.quizExtQ2A2,
                (l) => l.quizExtQ2A3, (l) => l.quizExtQ2A4],
      explanation: (l) => l.quizExtQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ3,
      options: [(l) => l.quizExtQ3A1, (l) => l.quizExtQ3A2,
                (l) => l.quizExtQ3A3, (l) => l.quizExtQ3A4],
      explanation: (l) => l.quizExtQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ4,
      options: [(l) => l.quizExtQ4A1, (l) => l.quizExtQ4A2,
                (l) => l.quizExtQ4A3, (l) => l.quizExtQ4A4],
      explanation: (l) => l.quizExtQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ5,
      options: [(l) => l.quizExtQ5A1, (l) => l.quizExtQ5A2,
                (l) => l.quizExtQ5A3, (l) => l.quizExtQ5A4],
      explanation: (l) => l.quizExtQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ6,
      options: [(l) => l.quizExtQ6A1, (l) => l.quizExtQ6A2,
                (l) => l.quizExtQ6A3, (l) => l.quizExtQ6A4],
      explanation: (l) => l.quizExtQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ7,
      options: [(l) => l.quizExtQ7A1, (l) => l.quizExtQ7A2,
                (l) => l.quizExtQ7A3, (l) => l.quizExtQ7A4],
      explanation: (l) => l.quizExtQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ8,
      options: [(l) => l.quizExtQ8A1, (l) => l.quizExtQ8A2,
                (l) => l.quizExtQ8A3, (l) => l.quizExtQ8A4],
      explanation: (l) => l.quizExtQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ9,
      options: [(l) => l.quizExtQ9A1, (l) => l.quizExtQ9A2,
                (l) => l.quizExtQ9A3, (l) => l.quizExtQ9A4],
      explanation: (l) => l.quizExtQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizExtQ10,
      options: [(l) => l.quizExtQ10A1, (l) => l.quizExtQ10A2,
                (l) => l.quizExtQ10A3, (l) => l.quizExtQ10A4],
      explanation: (l) => l.quizExtQ10Explain,
    ),
  ]),

  HygieneTipId.encryption: TipQuiz(tipId: HygieneTipId.encryption, questions: [
    QuizQuestion(
      question: (l) => l.quizEncryptQ1,
      options: [(l) => l.quizEncryptQ1A1, (l) => l.quizEncryptQ1A2,
                (l) => l.quizEncryptQ1A3, (l) => l.quizEncryptQ1A4],
      explanation: (l) => l.quizEncryptQ1Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ2,
      options: [(l) => l.quizEncryptQ2A1, (l) => l.quizEncryptQ2A2,
                (l) => l.quizEncryptQ2A3, (l) => l.quizEncryptQ2A4],
      explanation: (l) => l.quizEncryptQ2Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ3,
      options: [(l) => l.quizEncryptQ3A1, (l) => l.quizEncryptQ3A2,
                (l) => l.quizEncryptQ3A3, (l) => l.quizEncryptQ3A4],
      explanation: (l) => l.quizEncryptQ3Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ4,
      options: [(l) => l.quizEncryptQ4A1, (l) => l.quizEncryptQ4A2,
                (l) => l.quizEncryptQ4A3, (l) => l.quizEncryptQ4A4],
      explanation: (l) => l.quizEncryptQ4Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ5,
      options: [(l) => l.quizEncryptQ5A1, (l) => l.quizEncryptQ5A2,
                (l) => l.quizEncryptQ5A3, (l) => l.quizEncryptQ5A4],
      explanation: (l) => l.quizEncryptQ5Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ6,
      options: [(l) => l.quizEncryptQ6A1, (l) => l.quizEncryptQ6A2,
                (l) => l.quizEncryptQ6A3, (l) => l.quizEncryptQ6A4],
      explanation: (l) => l.quizEncryptQ6Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ7,
      options: [(l) => l.quizEncryptQ7A1, (l) => l.quizEncryptQ7A2,
                (l) => l.quizEncryptQ7A3, (l) => l.quizEncryptQ7A4],
      explanation: (l) => l.quizEncryptQ7Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ8,
      options: [(l) => l.quizEncryptQ8A1, (l) => l.quizEncryptQ8A2,
                (l) => l.quizEncryptQ8A3, (l) => l.quizEncryptQ8A4],
      explanation: (l) => l.quizEncryptQ8Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ9,
      options: [(l) => l.quizEncryptQ9A1, (l) => l.quizEncryptQ9A2,
                (l) => l.quizEncryptQ9A3, (l) => l.quizEncryptQ9A4],
      explanation: (l) => l.quizEncryptQ9Explain,
    ),
    QuizQuestion(
      question: (l) => l.quizEncryptQ10,
      options: [(l) => l.quizEncryptQ10A1, (l) => l.quizEncryptQ10A2,
                (l) => l.quizEncryptQ10A3, (l) => l.quizEncryptQ10A4],
      explanation: (l) => l.quizEncryptQ10Explain,
    ),
  ]),
};

