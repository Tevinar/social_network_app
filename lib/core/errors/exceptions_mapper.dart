import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';

/// Runs one remote data source operation behind a consistent exception
/// boundary.
///
/// The wrapped [call] is expected to perform transport or parsing work against
/// the backend. This helper translates low-level library exceptions into the
/// app's internal exception model so higher layers do not need to understand
/// Dio-specific failure details.
///
/// Mapping rules:
/// - network-level Dio failures become [NetworkException]
/// - normalized backend error payloads become [ServerException]
/// - malformed backend payloads become [InvalidResponseException]
/// - local parsing [FormatException]s become [InvalidResponseException]
/// - all other unclassified local failures become [UnexpectedException]
Future<T> guardRemoteDataSourceCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    if (_isNetworkDioException(e)) {
      throw NetworkException(message: e.message ?? 'Network request failed');
    }

    final responseData = e.response?.data;
    if (responseData == null) {
      throw const InvalidResponseException(
        message: 'Backend error response body is empty',
      );
    }

    throw parseServerExceptionPayload(responseData);
  } on InvalidResponseException {
    rethrow;
  } on NetworkException {
    rethrow;
  } on ServerException {
    rethrow;
  } on UnauthorizedException {
    rethrow;
  } on FormatException catch (e) {
    throw InvalidResponseException(message: e.message);
  } catch (e) {
    throw UnexpectedException(message: e.toString());
  }
}

/// Returns whether [e] represents a transport failure before any valid backend
/// response could be consumed.
///
/// These failures are mapped separately because there is no backend error
/// contract to parse when the connection itself fails.
bool _isNetworkDioException(DioException e) {
  return e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout;
}

/// Parses a backend error payload into a fully populated [ServerException].
///
/// Throws an [InvalidResponseException] when the payload does not match the
/// normalized backend error contract.
ServerException parseServerExceptionPayload(Object? data) {
  final json = _asJsonMap(data);
  if (json == null) {
    throw const InvalidResponseException(
      message: 'Backend error response is not a valid JSON object',
    );
  }

  final message = _requireString(json, 'message');
  final code = _requireString(json, 'code');
  final statusCode = _requireInt(json, 'statusCode');
  final path = _requireString(json, 'path');
  final timestamp = _requireTimestamp(json, 'timestamp');

  return ServerException(
    message: message,
    code: code,
    statusCode: statusCode,
    path: path,
    timestamp: timestamp,
  );
}

/// Attempts to normalize [data] into a JSON object map.
///
/// This helper accepts already-decoded object maps and JSON strings. It
/// returns `null` when [data] is empty, not an object, or cannot be safely
/// represented as `Map<String, dynamic>`.
Map<String, dynamic>? _asJsonMap(Object? data) {
  if (data is String) {
    if (data.isEmpty) {
      return null;
    }

    try {
      return _asJsonMap(jsonDecode(data));
    } on FormatException {
      return null;
    }
  }

  if (data is Map<String, dynamic>) {
    return data;
  }

  if (data is Map) {
    final normalized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      if (key is! String) {
        return null;
      }

      normalized[key] = entry.value;
    }

    return normalized;
  }

  return null;
}

/// Reads a required non-empty string field from a backend error payload.
///
/// Throws an [InvalidResponseException] when [field] is missing, is not a
/// string, or is empty.
String _requireString(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw InvalidResponseException(
    message: 'Backend error response has invalid "$field" field',
  );
}

/// Reads a required integer-like field from a backend error payload.
///
/// Numeric JSON values are accepted as long as they can be represented as an
/// integer. Throws an [InvalidResponseException] when [field] is missing or not
/// numeric.
int _requireInt(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  throw InvalidResponseException(
    message: 'Backend error response has invalid "$field" field',
  );
}

/// Reads a required ISO-8601 timestamp field from a backend error payload.
///
/// Throws an [InvalidResponseException] when [field] is missing, is not a
/// string, or cannot be parsed into a [DateTime].
DateTime _requireTimestamp(Map<String, dynamic> json, String field) {
  final value = json[field];
  if (value is! String) {
    throw InvalidResponseException(
      message: 'Backend error response has invalid "$field" field',
    );
  }

  final timestamp = DateTime.tryParse(value);
  if (timestamp == null) {
    throw InvalidResponseException(
      message: 'Backend error response has invalid "$field" field',
    );
  }

  return timestamp;
}
