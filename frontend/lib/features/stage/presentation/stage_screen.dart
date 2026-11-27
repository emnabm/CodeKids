import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/rewards/application/rewards_controller.dart';
import 'package:frontend/features/stage/application/stage_controller.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/features/stage/presentation/widgets/explanation_stage_view.dart';
import 'package:frontend/features/stage/presentation/widgets/hint_modal.dart';
import 'package:frontend/features/stage/presentation/widgets/quiz_stage_view.dart';
import 'package:frontend/features/stage/presentation/widgets/stage_complete_view.dart';
import 'package:frontend/shared/widgets/async_state_view.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

class StageScreen extends ConsumerWidget {
  const StageScreen({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final session = ref.watch(stageControllerProvider(stageId));
    final childFlames = ref.watch(
      childrenControllerProvider.select((s) => s.activeChild?.flames ?? 0),
    );

    ref.listen<Object?>(
      stageControllerProvider(stageId).select((s) => s.completeError),
      (previous, next) {
        if (next != null && next != previous && context.mounted) {
          final message = localizeApiError(l10n, next);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 6),
                action: SnackBarAction(
                  label: l10n.retry,
                  textColor: colors.flame,
                  onPressed: () => ref
                      .read(stageControllerProvider(stageId).notifier)
                      .completeStage(),
                ),
              ),
            );
        }
      },
    );

    if (session.completionResult != null && session.stage != null) {
      return StageCompleteView(
        stage: session.stage!,
        result: session.completionResult!,
        onContinue: () {
          ref.read(rewardsControllerProvider.notifier).loadRewards();
          context.pop();
        },
      );
    }

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.pop(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AsyncStateView(
                  isLoading: session.isLoading && session.stage == null,
                  error: session.stage == null ? session.loadError : null,
                  onRetry: () => ref
                      .read(stageControllerProvider(stageId).notifier)
                      .loadStage(stageId),
                  child: session.stage == null
                      ? const SizedBox.shrink()
                      : session.stage!.type == StageType.explanation
                          ? ExplanationStageView(
                              stage: session.stage!,
                              isCompleting: session.isCompleting,
                              onGotIt: () => ref
                                  .read(
                                    stageControllerProvider(stageId).notifier,
                                  )
                                  .completeStage(),
                            )
                          : QuizStageView(
                              session: session,
                              childFlames: childFlames,
                              onOpenHint: (question) {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) => HintModalDialog(
                                    initialFlames: childFlames,
                                    estimatedPrice:
                                        session.estimatedNextHintPrice,
                                    alreadyUnlockedHint:
                                        session.unlockedHints[question.id],
                                    onPurchaseHint: () => ref
                                        .read(
                                          stageControllerProvider(stageId)
                                              .notifier,
                                        )
                                        .purchaseHint(question.id),
                                  ),
                                );
                              },
                              onSubmitAnswer: ({
                                selectedText,
                                orderedItems,
                              }) async {
                                await ref
                                    .read(
                                      stageControllerProvider(stageId).notifier,
                                    )
                                    .submitAnswer(
                                      selectedText: selectedText,
                                      orderedItems: orderedItems,
                                    );
                              },
                              onRequeueWrong: () => ref
                                  .read(
                                    stageControllerProvider(stageId).notifier,
                                  )
                                  .requeueFailedAndContinue(),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
