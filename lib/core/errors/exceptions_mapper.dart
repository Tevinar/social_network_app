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

    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      throw ServerException(
        message: data['message'] as String? ?? 'Request failed',
        code: data['code'] as String? ?? e.response?.statusCode.toString(),
      );
    }

    throw ServerException(
      message: e.message ?? 'Request failed',
      code: e.response?.statusCode.toString(),
    );
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
