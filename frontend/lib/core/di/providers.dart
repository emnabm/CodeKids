import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/token_storage.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/chart/data/stats_repository.dart';
import 'package:frontend/features/children/data/children_repository.dart';
import 'package:frontend/features/map/data/map_repository.dart';
import 'package:frontend/features/rewards/data/rewards_repository.dart';
import 'package:frontend/features/stage/data/stage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Must be overridden in `main.dart` (or tests) before `ProviderScope` builds.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Single flag controlling Mock vs Live API repositories.
final useMockApiProvider = Provider<bool>((ref) => AppConfig.useMockApi);

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(prefs: ref.watch(sharedPreferencesProvider));
});

final mockBackendStateProvider = Provider<MockBackendState>((ref) {
  return MockBackendState();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(
    tokenStorage: storage,
    onUnauthorized: () {
      ref.read(authControllerProvider.notifier).handleUnauthorized();
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return MockAuthRepository(ref.watch(mockBackendStateProvider));
  }
  return ApiAuthRepository(ref.watch(apiClientProvider));
});

final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return MockChildrenRepository(ref.watch(mockBackendStateProvider));
  }
  return ApiChildrenRepository(ref.watch(apiClientProvider));
});

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return MockMapRepository(ref.watch(mockBackendStateProvider));
  }
  return ApiMapRepository(ref.watch(apiClientProvider));
});

final stageRepositoryProvider = Provider<StageRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return MockStageRepository(ref.watch(mockBackendStateProvider));
  }
  return ApiStageRepository(ref.watch(apiClientProvider));
});

final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return MockRewardsRepository(ref.watch(mockBackendStateProvider));
  }
  return ApiRewardsRepository(ref.watch(apiClientProvider));
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return MockStatsRepository(ref.watch(mockBackendStateProvider));
  }
  return ApiStatsRepository(ref.watch(apiClientProvider));
});
