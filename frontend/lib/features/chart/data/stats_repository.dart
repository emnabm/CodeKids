import 'package:dio/dio.dart';
import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/chart/data/models/stats_models.dart';

abstract class StatsRepository {
  Future<StatsResponseDto> getStats(String childId);
}

class ApiStatsRepository implements StatsRepository {
  ApiStatsRepository(this._client);

  final ApiClient _client;

  @override
  Future<StatsResponseDto> getStats(String childId) {
    return _client.guard(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/children/$childId/stats',
        options: Options(extra: const {'useParentAreaToken': true}),
      );
      return StatsResponseDto.fromJson(response.data ?? const {});
    });
  }
}

class MockStatsRepository implements StatsRepository {
  MockStatsRepository(this._state);

  final MockBackendState _state;

  @override
  Future<StatsResponseDto> getStats(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.getStats(childId);
  }
}
