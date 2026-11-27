import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/map/data/models/map_models.dart';

abstract class MapRepository {
  Future<MapResponseDto> getMap(String childId);
}

class ApiMapRepository implements MapRepository {
  ApiMapRepository(this._client);

  final ApiClient _client;

  @override
  Future<MapResponseDto> getMap(String childId) {
    return _client.guard(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/children/$childId/map',
      );
      return MapResponseDto.fromJson(response.data ?? const {});
    });
  }
}

class MockMapRepository implements MapRepository {
  MockMapRepository(this._state);

  final MockBackendState _state;

  @override
  Future<MapResponseDto> getMap(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.getMap(childId);
  }
}
