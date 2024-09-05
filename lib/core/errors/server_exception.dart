// core/error/exceptions/server_exception.dart

class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}