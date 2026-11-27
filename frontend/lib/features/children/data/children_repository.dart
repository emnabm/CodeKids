import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/children/data/models/child_models.dart';

abstract class ChildrenRepository {
  Future<List<ChildDto>> getChildren();
  Future<ChildDto> createChild(CreateChildRequestDto request);
  Future<void> deleteChild(String childId);
}

class ApiChildrenRepository implements ChildrenRepository {
  ApiChildrenRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ChildDto>> getChildren() {
    return _client.guard(() async {
      final response = await _client.dio.get<List<dynamic>>('/children');
      final list = response.data ?? const [];
      return list
          .whereType<Map>()
          .map((e) => ChildDto.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  @override
  Future<ChildDto> createChild(CreateChildRequestDto request) {
    return _client.guard(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/children',
        data: request.toJson(),
      );
      return ChildDto.fromJson(response.data ?? const {});
    });
  }

  @override
  Future<void> deleteChild(String childId) {
    return _client.guard(() async {
      await _client.dio.delete<void>('/children/$childId');
    });
  }
}

class MockChildrenRepository implements ChildrenRepository {
  MockChildrenRepository(this._state);

  final MockBackendState _state;

  @override
  Future<List<ChildDto>> getChildren() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.listChildren();
  }

  @override
  Future<ChildDto> createChild(CreateChildRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _state.createChild(request);
  }

  @override
  Future<void> deleteChild(String childId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _state.deleteChild(childId);
  }
}
