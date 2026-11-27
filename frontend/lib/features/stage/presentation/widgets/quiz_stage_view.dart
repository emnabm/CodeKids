import 'package:flutter/material.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/stage/application/stage_controller.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/features/stage/presentation/widgets/wrong_answer_panel.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Matches `docs/design/StageQuizz.png` and supports Mcq, TrueFalse, Order, FillBlank.
class QuizStageView extends StatefulWidget {
  const QuizStageView({
    super.key,
    required this.session,
    required this.childFlames,
    required this.onOpenHint,
    required this.onSubmitAnswer,
    required this.onRequeueWrong,
  });

  final StageSessionState session;
  final int childFlames;
  final ValueChanged<StageQuestionDto> onOpenHint;
  final Future<void> Function({
    String? selectedText,
    List<String>? orderedItems,
  }) onSubmitAnswer;
  final VoidCallback onRequeueWrong;

  @override
  State<QuizStageView> createState() => _QuizStageViewState();
}

class _QuizStageViewState extends State<QuizStageView> {
  String? _selectedText;
  final TextEditingController _fillInputController = TextEditingController();
  List<String> _currentOrder = const [];
  String? _activeQuestionKey;

  @override
  void initState() {
    super.initState();
    _syncQuestionState();
  }

  @override
  void didUpdateWidget(covariant QuizStageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncQuestionState();
  }

  @override
  void dispose() {
    _fillInputController.dispose();
    super.dispose();
  }

  void _syncQuestionState() {
    final q = widget.session.currentQuestion;
    if (q == null) return;
    final key = '${q.id}_${widget.session.attempts}_${widget.session.queue.length}';
    if (_activeQuestionKey == key) return;
    _activeQuestionKey = key;
    _selectedText = null;
    _fillInputController.clear();
    if (q.type == QuestionType.order) {
      _currentOrder = List<String>.from(
        widget.session.shuffledOrderOptions[q.id] ?? q.options,
      );
    } else {
      _currentOrder = const [];
    }
  }

  bool _canValidate(StageQuestionDto q) {
    if (widget.session.isCompleting) return false;
    switch (q.type) {
      case QuestionType.mcq:
      case QuestionType.trueFalse:
        return _selectedText != null;
      case QuestionType.order:
        return _currentOrder.isNotEmpty;
      case QuestionType.fillBlank:
        if (q.options.isEmpty) {
          return _fillInputController.text.trim().isNotEmpty;
        }
        return _selectedText != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final session = widget.session;
    final question = session.currentQuestion;

    if (question == null) {
      return const SizedBox.shrink();
    }

    if (session.showingWrongPanel) {
      return WrongAnswerPanel(
        correctAnswerDisplay: session.wrongCorrectAnswerDisplay,
        explanationText: question.explanationText ?? '',
        onContinue: widget.onRequeueWrong,
      );
    }

    final total = session.totalQuestions == 0 ? 1 : session.totalQuestions;
    final progress = (session.answeredCorrectly / total).clamp(0.0, 1.0);
    final hintDisabled = widget.childFlames < AppConfig.baseHintPrice;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          child: Column(
            children: [
              Text(
                l10n.quizProgress(session.currentDisplayNumber, total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 10,
                  width: double.infinity,
                  color: colors.card,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress == 0 ? 0.06 : progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [colors.success, const Color(0xFF34D399)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
                _buildQuestionBody(context, question),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            children: [
              Center(
                child: Material(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: hintDisabled ? null : () => widget.onOpenHint(question),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: hintDisabled
                              ? colors.border.withValues(alpha: 0.4)
                              : colors.flame.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            size: 20,
                            color: hintDisabled
                                ? colors.mutedText.withValues(alpha: 0.5)
                                : colors.flame,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.useHint(session.estimatedNextHintPrice),
                            style: TextStyle(
                              color: hintDisabled
                                  ? colors.mutedText.withValues(alpha: 0.5)
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.local_fire_department_rounded,
                            size: 18,
                            color: hintDisabled
                                ? colors.mutedText.withValues(alpha: 0.5)
                                : colors.flame,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: l10n.validate,
                isLoading: session.isCompleting,
                onPressed: _canValidate(question)
                    ? () {
                        if (question.type == QuestionType.order) {
                          widget.onSubmitAnswer(orderedItems: _currentOrder);
                        } else if (question.type == QuestionType.fillBlank &&
                            question.options.isEmpty) {
                          widget.onSubmitAnswer(
                            selectedText: _fillInputController.text.trim(),
                          );
                        } else {
                          widget.onSubmitAnswer(selectedText: _selectedText);
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBody(BuildContext context, StageQuestionDto question) {
    final colors = context.ckColors;
    switch (question.type) {
      case QuestionType.mcq:
      case QuestionType.trueFalse:
        return Column(
          children: [
            for (var i = 0; i < question.options.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _OptionCard(
                badge: question.type == QuestionType.mcq && i < 26
                    ? String.fromCharCode(65 + i)
                    : null,
                label: question.options[i],
                selected: _selectedText == question.options[i],
                onTap: () => setState(() {
                  _selectedText = question.options[i];
                }),
              ),
            ],
          ],
        );

      case QuestionType.order:
        return Column(
          children: [
            for (var i = 0; i < _currentOrder.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: colors.primary.withValues(alpha: 0.35),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentOrder[i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Move up',
                      onPressed: i == 0
                          ? null
                          : () => setState(() {
                                final item = _currentOrder.removeAt(i);
                                _currentOrder.insert(i - 1, item);
                              }),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                    IconButton(
                      tooltip: 'Move down',
                      onPressed: i == _currentOrder.length - 1
                          ? null
                          : () => setState(() {
                                final item = _currentOrder.removeAt(i);
                                _currentOrder.insert(i + 1, item);
                              }),
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

      case QuestionType.fillBlank:
        if (question.options.isEmpty) {
          return TextField(
            controller: _fillInputController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: '...',
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0622),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _selectedText != null
                      ? colors.success
                      : colors.border,
                ),
              ),
              child: Text(
                question.text.replaceAll(
                  '____',
                  _selectedText ?? '____',
                ),
                style: const TextStyle(
                  color: Color(0xFF7CE8FF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: question.options.map((chip) {
                final isSelected = _selectedText == chip;
                return ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      chip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: colors.primary,
                  backgroundColor: colors.card,
                  side: BorderSide(
                    color: isSelected ? colors.success : colors.border,
                  ),
                  onSelected: (_) => setState(() => _selectedText = chip),
                );
              }).toList(),
            ),
          ],
        );
    }
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    this.badge,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String? badge;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Material(
      color: selected
          ? const Color(0xFF12363F)
          : colors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? colors.success : colors.border,
              width: selected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              if (badge != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? colors.success
                        : colors.cardElevated,
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: selected ? colors.background : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Image.asset(
                  'assets/images/validation.png',
                  width: 24,
                  height: 24,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.check_circle_rounded,
                    color: colors.success,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
