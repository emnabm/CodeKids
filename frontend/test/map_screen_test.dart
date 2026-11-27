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
import 'package:frontend/features/map/application/map_controller.dart';
import 'package:frontend/features/map/data/models/map_models.dart';
import 'package:frontend/features/map/presentation/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'MapScreen prevents navigation on locked nodes (including double tap) and allows available nodes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final tapped = <String>[];
      const testMap = MapResponseDto(
        childId: 'child-1',
        childName: 'Emma',
        flames: 245,
        streakDays: 3,
        levels: [
          MapLevelDto(
            id: 'lvl-1',
            order: 1,
            title: 'Instructions',
            isLocked: false,
            stages: [
              MapStageDto(
                id: 's1',
                order: 1,
                type: 'Explanation',
                title: 'Welcome',
                rewardFlames: 10,
                status: StageStatus.completed,
                flamesEarned: 10,
                attempts: 1,
              ),
              MapStageDto(
                id: 's2',
                order: 2,
                type: 'Quiz',
                title: 'First Quiz',
                rewardFlames: 25,
                status: StageStatus.available,
                flamesEarned: 0,
                attempts: 0,
              ),
              MapStageDto(
                id: 's3',
                order: 3,
                type: 'Final',
                title: 'Final Test',
                rewardFlames: 60,
                status: StageStatus.locked,
                flamesEarned: 0,
                attempts: 0,
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            useMockApiProvider.overrideWithValue(true),
            tokenStorageProvider.overrideWithValue(
              TokenStorage(prefs: prefs, inMemoryOnly: true),
            ),
            childrenControllerProvider.overrideWith(
              () => _FixedChildrenController(
                const ChildDto(
                  id: 'child-1',
                  name: 'Emma',
                  age: 10,
                  avatarId: 'avatar_astronaut_girl',
                  flames: 245,
                  streakDays: 3,
                ),
              ),
            ),
            mapControllerProvider.overrideWith(
              () => _FixedMapController(testMap),
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
            home: MapScreen(
              onStageTap: (stage) => tapped.add(stage.id),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header displays child name and flames
      expect(find.text('Emma'), findsOneWidget);
      expect(find.text('245'), findsOneWidget);

      // Double-tap locked stage (s3) -> must not trigger navigation
      await tester.tap(find.text('Final Test'));
      await tester.tap(find.text('Final Test'));
      await tester.pump();
      expect(tapped, isEmpty);

      // Tap available stage (s2) -> triggers navigation
      await tester.tap(find.text('2'));
      await tester.pump();
      expect(tapped, ['s2']);
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

class _FixedMapController extends MapController {
  _FixedMapController(this._map);
  final MapResponseDto _map;

  @override
  MapState build() => MapState(data: _map, isLoading: false);
}
