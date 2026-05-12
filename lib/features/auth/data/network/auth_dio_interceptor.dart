import 'dart:io';

import 'package:dio/dio.dart';
import 'package:social_app/features/auth/data/session/auth_token_manager.dart';

/// Dio interceptor that attaches a valid bearer token and retries once after
/// an auth refresh when the backend responds with `401` or `403`.
class AuthDioInterceptor extends QueuedInterceptor {
  /// Creates an [AuthDioInterceptor].
  AuthDioInterceptor({
    required Dio dio,
    required AuthTokenManager authTokenManager,
  }) : _dio = dio,
       _authTokenManager = authTokenManager;

  final Dio _dio;
  final AuthTokenManager _authTokenManager;

  static const _retriedKey = 'auth_retry_done';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _authTokenManager.getValidAccessToken();

      if (accessToken == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const HttpException('Missing auth session'),
          ),
        );
      }

      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';

      handler.next(options);
    } on Object catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
        ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;

    if ((statusCode != 401 && statusCode != 403) || alreadyRetried) {
      return handler.next(err);
    }

    try {
      final newAccessToken = await _authTokenManager.forceRefreshAccessToken();

      final retriedOptions = err.requestOptions.copyWith(
        headers: {
          ...err.requestOptions.headers,
          HttpHeaders.authorizationHeader: 'Bearer $newAccessToken',
        },
        extra: {
          ...err.requestOptions.extra,
          _retriedKey: true,
        },
      );

      final response = await _dio.fetch<dynamic>(retriedOptions);
      handler.resolve(response);
    } on Object catch (_) {
      handler.next(err);
    }
  }
}
