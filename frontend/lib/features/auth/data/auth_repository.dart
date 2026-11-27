import 'package:frontend/core/mock/mock_backend_state.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/data/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponseDto> register(RegisterRequestDto request);
  Future<AuthResponseDto> login(LoginRequestDto request);
  Future<VerifyPinResponseDto> verifyPin(VerifyPinRequestDto request);
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) {
    return _client.guard(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data ?? const {});
    });
  }

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) {
    return _client.guard(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data ?? const {});
    });
  }

  @override
  Future<VerifyPinResponseDto> verifyPin(VerifyPinRequestDto request) {
    return _client.guard(() async {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/verify-pin',
        data: request.toJson(),
      );
      return VerifyPinResponseDto.fromJson(response.data ?? const {});
    });
  }
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._state);

  final MockBackendState _state;

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _state.register(request);
  }

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _state.login(request);
  }

  @override
  Future<VerifyPinResponseDto> verifyPin(VerifyPinRequestDto request) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state.verifyPin(request);
  }
}
