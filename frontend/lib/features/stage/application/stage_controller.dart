import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/utils/dto_bounds.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/map/application/map_controller.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';

class StageSessionState {
  const StageSessionState({
    this.stage,
    this.isLoading = false,
    this.loadError,
    this.queue = const [],
    this.totalQuestions = 0,
    this.answeredCorrectly = 0,
    this.attempts = 0,
    this.hintsUsed = 0,
    this.unlockedHints = const {},
    this.shuffledOrderOptions = const {},
    this.showingWrongPanel = false,
    this.wrongCorrectAnswerDisplay = '',
    this.isCompleting = false,
    this.completeError,
    this.completionResult,
  });

  final StageDetailDto? stage;
  final bool isLoading;
  final Object? loadError;
  final List<StageQuestionDto> queue;
  final int totalQuestions;
  final int answeredCorrectly;
  final int attempts;
  final int hintsUsed;
  final Map<String, String> unlockedHints;
  final Map<String, List<String>> shuffledOrderOptions;
  final bool showingWrongPanel;
  final String wrongCorrectAnswerDisplay;
  final bool isCompleting;
  final Object? completeError;
  final CompleteStageResponseDto? completionResult;

  StageQuestionDto? get currentQuestion => queue.isEmpty ? null : queue.first;

  int get estimatedNextHintPrice =>
      AppConfig.baseHintPrice + (hintsUsed * AppConfig.hintPriceStep);

  int get currentDisplayNumber {
    if (totalQuestions == 0) return 0;
    return (answeredCorrectly + 1).clamp(1, totalQuestions);
  }

  StageSessionState copyWith({
    StageDetailDto? stage,
    bool? isLoading,
    Object? loadError,
    bool clearLoadError = false,
    List<StageQuestionDto>? queue,
    int? totalQuestions,
    int? answeredCorrectly,
    int? attempts,
    int? hintsUsed,
    Map<String, String>? unlockedHints,
    Map<String, List<String>>? shuffledOrderOptions,
    bool? showingWrongPanel,
    String? wrongCorrectAnswerDisplay,
    bool? isCompleting,
    Object? completeError,
    bool clearCompleteError = false,
    CompleteStageResponseDto? completionResult,
  }) {
    return StageSessionState(
      stage: stage ?? this.stage,
      isLoading: isLoading ?? this.isLoading,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      queue: queue ?? this.queue,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      answeredCorrectly: answeredCorrectly ?? this.answeredCorrectly,
      attempts: attempts ?? this.attempts,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      unlockedHints: unlockedHints ?? this.unlockedHints,
      shuffledOrderOptions: shuffledOrderOptions ?? this.shuffledOrderOptions,
      showingWrongPanel: showingWrongPanel ?? this.showingWrongPanel,
      wrongCorrectAnswerDisplay:
          wrongCorrectAnswerDisplay ?? this.wrongCorrectAnswerDisplay,
      isCompleting: isCompleting ?? this.isCompleting,
      completeError:
          clearCompleteError ? null : (completeError ?? this.completeError),
      completionResult: completionResult ?? this.completionResult,
    );
  }
}

class StageController
    extends AutoDisposeFamilyNotifier<StageSessionState, String> {
  @override
  StageSessionState build(String arg) {
    Future.microtask(() => loadStage(arg));
    return const StageSessionState(isLoading: true);
  }

  Future<void> loadStage(String stageId) async {
    final childId = ref.read(childrenControllerProvider).activeChildId;
    if (childId == null) return;

    state = state.copyWith(isLoading: true, clearLoadError: true);
    try {
      final detail = await ref.read(stageRepositoryProvider).getStage(
            stageId: stageId,
            childId: childId,
          );

      final rng = math.Random();
      final shuffledMap = <String, List<String>>{};
      for (final q in detail.questions) {
        if (q.type == QuestionType.order) {
          final copy = [...q.options];
          if (copy.length > 1) {
            copy.shuffle(rng);
          }
          shuffledMap[q.id] = copy;
        }
      }

      state = StageSessionState(
        stage: detail,
        isLoading: false,
        queue: List<StageQuestionDto>.from(detail.questions),
        totalQuestions: detail.questions.length,
        shuffledOrderOptions: shuffledMap,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, loadError: e);
    }
  }

  Future<HintResponseDto> purchaseHint(String questionId) async {
    final stage = state.stage;
    final childId = ref.read(childrenControllerProvider).activeChildId;
    if (stage == null || childId == null) {
      throw StateError('Stage or child not loaded');
    }

    final response = await ref.read(stageRepositoryProvider).purchaseHint(
          stageId: stage.id,
          request: HintRequestDto(
            childId: childId,
            questionId: questionId,
          ),
        );

    ref
        .read(childrenControllerProvider.notifier)
        .updateActiveChildMetrics(flames: response.flamesLeft);

    final updatedHints = Map<String, String>.from(state.unlockedHints);
    updatedHints[questionId] = response.hintText ?? '';

    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      unlockedHints: updatedHints,
    );
    return response;
  }

  /// Submits an answer for the front question in the queue.
  ///
  /// Returns `true` if correct, `false` if wrong (shows wrong-answer panel).
  Future<bool> submitAnswer({
    String? selectedText,
    List<String>? orderedItems,
  }) async {
    final question = state.currentQuestion;
    if (question == null) return false;

    final nextAttempts = state.attempts + 1;
    final bool isCorrect;
    final String correctDisplay;

    switch (question.answer) {
      case CorrectValueAnswer(:final correct):
        isCorrect = (selectedText ?? '').trim() == correct.trim();
        if (question.type == QuestionType.mcq) {
          final idx = question.options.indexWhere(
            (o) => o.trim() == correct.trim(),
          );
          if (idx >= 0 && idx < 26) {
            final letter = String.fromCharCode(65 + idx);
            correctDisplay = '$letter ($correct)';
          } else {
            correctDisplay = correct;
          }
        } else {
          correctDisplay = correct;
        }
      case OrderedValuesAnswer(:final order):
        final submitted = orderedItems ?? const [];
        isCorrect = listEquals(submitted, order);
        correctDisplay = order.join(' → ');
    }

    if (isCorrect) {
      final remaining = [...state.queue]..removeAt(0);
      state = state.copyWith(
        attempts: nextAttempts,
        answeredCorrectly: state.answeredCorrectly + 1,
        queue: remaining,
        showingWrongPanel: false,
      );
      if (remaining.isEmpty) {
        await completeStage();
      }
      return true;
    } else {
      state = state.copyWith(
        attempts: nextAttempts,
        showingWrongPanel: true,
        wrongCorrectAnswerDisplay: correctDisplay,
      );
      return false;
    }
  }

  /// Moves the failed question from the front to the END of the queue.
  void requeueFailedAndContinue() {
    if (state.queue.isEmpty) return;
    final updatedQueue = [...state.queue];
    final failed = updatedQueue.removeAt(0);
    updatedQueue.add(failed);
    state = state.copyWith(
      queue: updatedQueue,
      showingWrongPanel: false,
      wrongCorrectAnswerDisplay: '',
    );
  }

  Future<CompleteStageResponseDto?> completeStage() async {
    final stage = state.stage;
    final childId = ref.read(childrenControllerProvider).activeChildId;
    if (stage == null || childId == null || state.isCompleting) return null;

    state = state.copyWith(isCompleting: true, clearCompleteError: true);
    try {
      final result = await ref.read(stageRepositoryProvider).completeStage(
            stageId: stage.id,
            request: CompleteStageRequestDto(
              childId: childId,
              hintsUsed: RequestBounds.clampHintsUsed(state.hintsUsed),
              attempts: RequestBounds.clampAttempts(state.attempts),
            ),
          );

      ref.read(childrenControllerProvider.notifier).updateActiveChildMetrics(
            flames: result.flamesTotal,
            streakDays: result.streakDays,
          );
      // Refresh map in background so unlocked/completed nodes are current.
      ref.read(mapControllerProvider.notifier).loadMap(childId: childId);

      state = state.copyWith(
        isCompleting: false,
        completionResult: result,
      );
      return result;
    } catch (e) {
      state = state.copyWith(isCompleting: false, completeError: e);
      return null;
    }
  }
}

final stageControllerProvider = AutoDisposeNotifierProviderFamily<
    StageController, StageSessionState, String>(
  StageController.new,
);
