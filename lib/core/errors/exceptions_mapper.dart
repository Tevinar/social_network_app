import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';

/// Runs a remote data source call and maps infrastructure errors to app
/// exceptions.

Future<T> guardRemoteDataSourceCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    if (_isNetworkDioException(e)) {
      throw NetworkException(message: e.message ?? 'Network request failed');
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    final message = data is Map<String, dynamic>
        ? data['message'] as String? ?? e.message ?? 'Request failed'
        : e.message ?? 'Request failed';

    final code = data is Map<String, dynamic>
        ? data['code'] as String? ?? statusCode?.toString()
        : statusCode?.toString();

    if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException(
        message: message,
        code: code,
      );
    }

    throw ServerException(
      message: message,
      code: code,
    );
  } on UnauthorizedException {
    rethrow;
  } catch (e) {
    throw ServerException(message: e.toString());
  }
}

bool _isNetworkDioException(DioException e) {
  return e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;
}
