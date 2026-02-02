class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  const NetworkException({required this.message, this.code});

  @override
  String toString() => 'NetworkException: $message (code: $code)';
}
