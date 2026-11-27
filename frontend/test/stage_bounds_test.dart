import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations_en.dart';
import 'package:frontend/core/network/problem_details.dart';
import 'package:frontend/core/network/token_storage.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/children/data/models/child_models.dart';
import 'package:frontend/features/stage/application/stage_controller.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/features/stage/data/stage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Explanation stage sends attempts = 1', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = _RecordingStageRepository(type: 'Explanation');

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        useMockApiProvider.overrideWithValue(true),
        tokenStorageProvider.overrideWithValue(
          TokenStorage(prefs: prefs, inMemoryOnly: true),
        ),
        stageRepositoryProvider.overrideWithValue(fakeRepo),
        childrenControllerProvider.overrideWith(
          () => _FixedChildrenController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(
      stageControllerProvider('stage-exp'),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await container
        .read(stageControllerProvider('stage-exp').notifier)
        .completeStage();

    expect(fakeRepo.lastCompleteRequest, isNotNull);
    expect(fakeRepo.lastCompleteRequest!.toJson()['attempts'], 1);
    expect(fakeRepo.lastCompleteRequest!.toJson()['hintsUsed'], 0);
  });

  test('Quiz with 150 submitted answers sends attempts = 100', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final fakeRepo = _RecordingStageRepository(type: 'Quiz');

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        useMockApiProvider.overrideWithValue(true),
        tokenStorageProvider.overrideWithValue(
          TokenStorage(prefs: prefs, inMemoryOnly: true),
        ),
        stageRepositoryProvider.overrideWithValue(fakeRepo),
        childrenControllerProvider.overrideWith(
          () => _FixedChildrenController(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final sub = container.listen(
      stageControllerProvider('stage-quiz'),
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    await Future<void>.delayed(const Duration(milliseconds: 20));
    final notifier =
        container.read(stageControllerProvider('stage-quiz').notifier);

    // Submit 149 wrong answers + requeue, then 1 right answer -> 150 attempts.
    for (var i = 0; i < 149; i++) {
      await notifier.submitAnswer(selectedText: 'Wrong');
      notifier.requeueFailedAndContinue();
    }
    await notifier.submitAnswer(selectedText: 'Right');

    expect(fakeRepo.lastCompleteRequest, isNotNull);
    expect(fakeRepo.lastCompleteRequest!.toJson()['attempts'], 100);
  });

  test('400 validation errors map to child-friendly message', () {
    final l10n = AppLocalizationsEn();
    const exception = ApiException(
      kind: ApiErrorKind.badRequest,
      statusCode: 400,
      problemDetails: ProblemDetails(
        status: 400,
        title: 'One or more validation errors occurred.',
        errors: {
          'Attempts': ['The field Attempts must be between 1 and 100.'],
        },
      ),
    );

    final msg = localizeApiError(l10n, exception, preferServerMessage: true);
    expect(msg, l10n.errorValidation);
    expect(msg.contains('Attempts'), isFalse);
  });
}

class _FixedChildrenController extends ChildrenController {
  @override
  ChildrenState build() => const ChildrenState(
        children: [
          ChildDto(
            id: 'child-1',
            name: 'Alex',
            age: 10,
            avatarId: 'avatar_robot_blue',
            flames: 100,
            streakDays: 1,
          ),
        ],
        activeChildId: 'child-1',
      );
}

class _RecordingStageRepository implements StageRepository {
  _RecordingStageRepository({required this.type});

  final String type;
  CompleteStageRequestDto? lastCompleteRequest;

  @override
  Future<StageDetailDto> getStage({
    required String stageId,
    required String childId,
  }) async {
    return StageDetailDto.fromJson({
      'id': stageId,
      'levelId': 'lvl-1',
      'order': 1,
      'type': type,
      'title': 'Sample',
      'rewardFlames': 10,
      'questions': type == 'Explanation'
          ? []
          : [
              {
                'id': 'q1',
                'type': 'Mcq',
                'text': 'Pick Right',
                'options': ['Right', 'Wrong'],
                'answer': {'correct': 'Right'},
              },
            ],
    });
  }

  @override
  Future<HintResponseDto> purchaseHint({
    required String stageId,
    required HintRequestDto request,
  }) async {
    return const HintResponseDto(hintText: 'Hint', cost: 100, flamesLeft: 0);
  }

  @override
  Future<CompleteStageResponseDto> completeStage({
    required String stageId,
    required CompleteStageRequestDto request,
  }) async {
    lastCompleteRequest = request;
    return const CompleteStageResponseDto(
      flamesEarned: 10,
      streakBonus: 0,
      flamesTotal: 110,
      streakDays: 1,
      newBadges: [],
    );
  }
}
