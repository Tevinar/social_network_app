class ServerException implements Exception {
  const ServerException({required this.message, this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

class NetworkException implements Exception {
  const NetworkException({required this.message, this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'NetworkException: $message (code: $code)';
}
