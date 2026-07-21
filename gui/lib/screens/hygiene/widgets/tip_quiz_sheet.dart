
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../quiz_data.dart';

Future<void> showQuizDialog({
  required BuildContext context,
  required TipQuiz quiz,
  required AppLocalizations l10n,
  Set<int> seenIndices = const {},
  required void Function(int correct, int total, List<int> shownIndices) onCompleted,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _QuizDialog(
      quiz: quiz,
      l10n: l10n,
      seenIndices: seenIndices,
      onCompleted: onCompleted,
    ),
  );
}

class _QuizDialog extends StatefulWidget {
  final TipQuiz quiz;
  final AppLocalizations l10n;
  final Set<int> seenIndices;
  final void Function(int correct, int total, List<int> shownIndices) onCompleted;

  const _QuizDialog({
    required this.quiz,
    required this.l10n,
    required this.seenIndices,
    required this.onCompleted,
  });

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  static const _questionsPerSession = 5;

  int _currentQuestion = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _finished = false;
  late List<List<_ShuffledOption>> _shuffledQuestions;
  late List<int> _questionOrder;

  int get _totalInSession => _questionOrder.length;

  int get _qi => _questionOrder[_currentQuestion];

  @override
  void initState() {
    super.initState();
    _reshuffleAll();
  }

  void _reshuffleAll() {
    final rng = Random();
    final allCount = widget.quiz.questions.length;
    final allIndices = List.generate(allCount, (i) => i)..shuffle(rng);

    var unseen = allIndices.where((i) => !widget.seenIndices.contains(i)).toList();
    if (unseen.isEmpty) unseen = allIndices;

    _questionOrder = unseen.take(
      unseen.length <= _questionsPerSession ? unseen.length : _questionsPerSession,
    ).toList();
    _shuffledQuestions = widget.quiz.questions.map((q) {
      final indexed = q.options.asMap().entries.map((e) =>
        _ShuffledOption(originalIndex: e.key, getText: e.value),
      ).toList()..shuffle(rng);
      return indexed;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = widget.l10n;
    final colors = context.read<AppStateProvider>().colors;
    final total  = _totalInSession;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz_outlined, color: colors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.quizTitle,
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeHeader,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (!_finished)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_currentQuestion + 1}/$total',
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeLabel,
                          fontWeight: FontWeight.w700,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 22),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),

              if (!_finished) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentQuestion + (_answered ? 1 : 0)) / total,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                    minHeight: 5,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (_finished)
                _buildResult(colors, l10n, total)
              else
                _buildQuestion(colors, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(AdaptiveColors colors, AppLocalizations l10n) {
    final q = widget.quiz.questions[_qi];
    final shuffled = _shuffledQuestions[_qi];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.question(l10n),
          style: TextStyle(
            fontSize: AppTextStyles.sizeMedium,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),

        ...shuffled.asMap().entries.map((entry) {
          final i = entry.key;
          final opt = entry.value;
          final isCorrect = opt.originalIndex == 0;
          final isSelected = _selectedIndex == i;

          Color? bgColor;
          Color? borderColor;
          IconData? icon;

          if (_answered) {
            if (isCorrect) {
              bgColor = colors.success.withValues(alpha: 0.12);
              borderColor = colors.success;
              icon = Icons.check_circle;
            } else if (isSelected) {
              bgColor = colors.danger.withValues(alpha: 0.12);
              borderColor = colors.danger;
              icon = Icons.cancel;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: _answered ? null : () => _answer(i, isCorrect),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor ??
                      colors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor ??
                        colors.divider.withValues(alpha: 0.5),
                    width: _answered && (isCorrect || isSelected) ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: borderColor),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Text(
                        opt.getText(l10n),
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeLabel,
                          color: colors.textPrimary,
                          fontWeight: _answered && isCorrect
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        if (_answered) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 20, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.quiz.questions[_qi].explanation(l10n),
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeBody,
                      color: colors.textPrimary.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _next,
              icon: Icon(
                _currentQuestion < _totalInSession - 1
                    ? Icons.arrow_forward
                    : Icons.done_all,
                size: 18,
              ),
              label: Text(
                _currentQuestion < _totalInSession - 1
                    ? l10n.quizNext
                    : l10n.quizFinish,
                style: const TextStyle(fontSize: AppTextStyles.sizeLabel),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResult(AdaptiveColors colors, AppLocalizations l10n, int total) {
    final allCorrect = _correctCount == total;
    final color = allCorrect
        ? colors.success
        : _correctCount > 0
            ? colors.warning
            : colors.danger;

    return Column(
      children: [
        const SizedBox(height: 8),
        Icon(
          allCorrect ? Icons.emoji_events : Icons.school_outlined,
          size: 56,
          color: color,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.quizResultTitle,
          style: TextStyle(
            fontSize: AppTextStyles.sizeHeader,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.quizResultScore(_correctCount, total),
          style: TextStyle(
            fontSize: AppTextStyles.sizeMedium,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          allCorrect ? l10n.quizResultPerfect : l10n.quizResultKeepLearning,
          style: TextStyle(
            fontSize: AppTextStyles.sizeBody,
            color: colors.textSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retake,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.quizRetake,
                    style: const TextStyle(fontSize: AppTextStyles.sizeBody)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.quizClose,
                    style: const TextStyle(fontSize: AppTextStyles.sizeBody)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _answer(int shuffledIndex, bool isCorrect) {
    setState(() {
      _selectedIndex = shuffledIndex;
      _answered = true;
      if (isCorrect) _correctCount++;
    });
  }

  void _next() {
    if (_currentQuestion < _totalInSession - 1) {
      setState(() {
        _currentQuestion++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      setState(() => _finished = true);
      widget.onCompleted(_correctCount, _totalInSession, _questionOrder);
    }
  }

  void _retake() {
    setState(() {
      _currentQuestion = 0;
      _correctCount = 0;
      _selectedIndex = null;
      _answered = false;
      _finished = false;
      _reshuffleAll();
    });
  }
}

class _ShuffledOption {
  final int originalIndex;
  final String Function(AppLocalizations) getText;
  const _ShuffledOption({required this.originalIndex, required this.getText});
}

