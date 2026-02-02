class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException({required this.message, this.code});
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  const NetworkException({required this.message, this.code});
}
