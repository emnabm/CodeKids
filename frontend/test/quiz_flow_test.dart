import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/network/token_storage.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/children/data/models/child_models.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/features/stage/data/stage_repository.dart';
import 'package:frontend/features/stage/presentation/stage_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Quiz queue puts wrong answer at the end and completes only when queue is empty',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final fakeRepo = _FakeStageRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            useMockApiProvider.overrideWithValue(true),
            tokenStorageProvider.overrideWithValue(
              TokenStorage(prefs: prefs, inMemoryOnly: true),
            ),
            stageRepositoryProvider.overrideWithValue(fakeRepo),
            childrenControllerProvider.overrideWith(
              () => _FixedChildrenController(
                const ChildDto(
                  id: 'child-1',
                  name: 'Alex',
                  age: 10,
                  avatarId: 'avatar_robot_blue',
                  flames: 50, // < 100 -> hint button disabled
                  streakDays: 1,
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.buildDarkTheme(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const StageScreen(stageId: 'stage-quiz'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Question 1 shown; balance is 50 (< 100) so hint button is disabled.
      expect(find.text('Question One?'), findsOneWidget);
      final hintInk = tester.widget<InkWell>(
        find.ancestor(
          of: find.textContaining('Hint'),
          matching: find.byType(InkWell),
        ),
      );
      expect(hintInk.onTap, isNull);

      // Submit WRONG answer on Question 1
      await tester.tap(find.text('Wrong'));
      await tester.pump();
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect!'), findsOneWidget);
      expect(fakeRepo.completeCalls, 0);

      // Tap Try again -> Question 1 moves to END, Question 2 comes up
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Question Two?'), findsOneWidget);

      // Answer Question 2 CORRECTLY -> Question 1 comes back!
      await tester.tap(find.text('Right2'));
      await tester.pump();
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();

      expect(find.text('Question One?'), findsOneWidget);
      expect(fakeRepo.completeCalls, 0);

      // Answer Question 1 CORRECTLY -> queue is now empty -> completeStage called once
      await tester.tap(find.text('Right1'));
      await tester.pump();
      await tester.tap(find.text('Validate'));
      await tester.pumpAndSettle();

      expect(fakeRepo.completeCalls, 1);
      expect(find.text('Stage complete!'), findsOneWidget);
    },
  );
}

class _FixedChildrenController extends ChildrenController {
  _FixedChildrenController(this._child);
  final ChildDto _child;

  @override
  ChildrenState build() => ChildrenState(
        children: [_child],
        activeChildId: _child.id,
      );
}

class _FakeStageRepository implements StageRepository {
  int completeCalls = 0;

  @override
  Future<StageDetailDto> getStage({
    required String stageId,
    required String childId,
  }) async {
    return StageDetailDto.fromJson({
      'id': stageId,
      'levelId': 'lvl-1',
      'order': 2,
      'type': 'Quiz',
      'title': 'Test Quiz',
      'rewardFlames': 25,
      'questions': [
        {
          'id': 'q1',
          'type': 'Mcq',
          'text': 'Question One?',
          'options': ['Wrong', 'Right1'],
          'answer': {'correct': 'Right1'},
          'hintText': 'Hint 1',
          'explanationText': 'Because Right1.',
        },
        {
          'id': 'q2',
          'type': 'Mcq',
          'text': 'Question Two?',
          'options': ['Right2', 'Wrong2'],
          'answer': {'correct': 'Right2'},
          'hintText': 'Hint 2',
          'explanationText': 'Because Right2.',
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
    completeCalls++;
    return const CompleteStageResponseDto(
      flamesEarned: 25,
      streakBonus: 0,
      flamesTotal: 75,
      streakDays: 1,
      newBadges: [],
    );
  }
}
