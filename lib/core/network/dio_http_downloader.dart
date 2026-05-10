import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:social_app/core/logging/app_logger.dart';

/// Downloads remote resources as raw bytes.
///
/// This implementation uses `ResponseType.bytes` so binary resources such as
/// images can be downloaded without text decoding.
class DioHttpDownloader {
  /// Creates a [DioHttpDownloader].
  DioHttpDownloader(this._dio);

  /// HTTP client used to perform downloads.
  final Dio _dio;

  /// Downloads the resource at [uri] and returns its raw bytes.
  ///
  /// Any transport or HTTP errors are logged and then rethrown to the caller.
  Future<Uint8List> downloadBytes(Uri uri) async {
    try {
      final response = await _dio.get<List<int>>(
        uri.toString(),
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final data = response.data;
      if (data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Image response body is empty',
        );
      }

      return Uint8List.fromList(data);
    } catch (e, stackTrace) {
      appLogger.error(
        'Error downloading resource from $uri',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
