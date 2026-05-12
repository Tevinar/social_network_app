/// Represents server exception.
class ServerException implements Exception {
  /// Creates a [ServerException].
  const ServerException({required this.message, this.code});

  /// The message.
  final String message;

  /// The code.
  final String? code;

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

/// Represents network exception.
class NetworkException implements Exception {
  /// Creates a [NetworkException].
  const NetworkException({required this.message, this.code});

  /// The message.
  final String message;

  /// The code.
  final String? code;

  @override
  String toString() => 'NetworkException: $message (code: $code)';
}

/// Represents an authentication / authorization exception.
class UnauthorizedException implements Exception {
  /// Creates an [UnauthorizedException].
  const UnauthorizedException({required this.message, this.code});

  /// The message.
  final String message;

  /// The code.
  final String? code;

  @override
  String toString() => 'UnauthorizedException: $message (code: $code)';
}
