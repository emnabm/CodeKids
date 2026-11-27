import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/network/problem_details.dart';
import 'package:frontend/core/network/token_storage.dart';

/// Configured Dio client with Bearer JWT injection and 401 session handling.
class ApiClient {
  ApiClient({
    required this._tokenStorage,
    required this._onUnauthorized,
    Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    this.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final useParentToken =
                  options.extra['useParentAreaToken'] == true;
              final token = useParentToken
                  ? _tokenStorage.parentAreaToken
                  : await _tokenStorage.readToken();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              handler.next(options);
            },
            onError: (error, handler) async {
              final statusCode = error.response?.statusCode;
              final path = error.requestOptions.path;
              final isParentStatsCall =
                  error.requestOptions.extra['useParentAreaToken'] == true;
              final isAuthEndpoint = path.startsWith('/auth/login') ||
                  path.startsWith('/auth/register') ||
                  path.startsWith('/auth/verify-pin');

              if (statusCode == 401 && !isAuthEndpoint && !isParentStatsCall) {
                await _tokenStorage.clearSession();
                _onUnauthorized();
              } else if ((statusCode == 401 || statusCode == 403) &&
                  isParentStatsCall) {
                _tokenStorage.clearParentAreaToken();
              }
              handler.next(error);
            },
          ),
        );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;
  final VoidCallback _onUnauthorized;

  /// Wraps a Dio call and converts errors into normalized [ApiException]s.
  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
