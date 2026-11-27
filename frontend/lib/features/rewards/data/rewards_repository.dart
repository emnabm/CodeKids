import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/rewards/data/models/reward_models.dart';

abstract class RewardsRepository {
  Future<RewardResponseDto> getRewards(String childId);
}

class ApiRewardsRepository implements RewardsRepository {
  ApiRewardsRepository(this._client);

  final ApiClient _client;

  @override
  Future<RewardResponseDto> getRewards(String childId) {
    return _client.guard(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/children/$childId/rewards',
      );
      return RewardResponseDto.fromJson(response.data ?? const {});
    });
  }
}

class MockRewardsRepository implements RewardsRepository {
  MockRewardsRepository(this._state);

  final MockBackendState _state;

  @override
  Future<RewardResponseDto> getRewards(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.getRewards(childId);
  }
}
