import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';

abstract class StageRepository {
  Future<StageDetailDto> getStage({
    required String stageId,
    required String childId,
  });

  Future<HintResponseDto> purchaseHint({
    required String stageId,
    required HintRequestDto request,
  });

  Future<CompleteStageResponseDto> completeStage({
    required String stageId,
    required CompleteStageRequestDto request,
  });
}

class ApiStageRepository implements StageRepository {
  ApiStageRepository(this._client);

  final ApiClient _client;

  @override
  Future<StageDetailDto> getStage({
    required String stageId,
    required String childId,
  }) {
    return _client.guard(() async {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '/stages/$stageId',
        queryParameters: {'childId': childId},
      );
      return StageDetailDto.fromJson(response.data ?? const {});
    });
  }

  @override
  Future<HintResponseDto> purchaseHint({
    required String stageId,
    required HintRequestDto request,
  }) {
    return _client.guard(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/stages/$stageId/hint',
        data: request.toJson(),
      );
      return HintResponseDto.fromJson(response.data ?? const {});
    });
  }

  @override
  Future<CompleteStageResponseDto> completeStage({
    required String stageId,
    required CompleteStageRequestDto request,
  }) {
    return _client.guard(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/stages/$stageId/complete',
        data: request.toJson(),
      );
      return CompleteStageResponseDto.fromJson(response.data ?? const {});
    });
  }
}

class MockStageRepository implements StageRepository {
  MockStageRepository(this._state);

  final MockBackendState _state;

  @override
  Future<StageDetailDto> getStage({
    required String stageId,
    required String childId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.getStageDetail(stageId, childId);
  }

  @override
  Future<HintResponseDto> purchaseHint({
    required String stageId,
    required HintRequestDto request,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.buyHint(stageId, request);
  }

  @override
  Future<CompleteStageResponseDto> completeStage({
    required String stageId,
    required CompleteStageRequestDto request,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _state.completeStage(stageId, request);
  }
}
