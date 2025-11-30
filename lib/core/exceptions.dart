class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class DatabaseException extends AppException {
  DatabaseException(String message, {dynamic originalError})
      : super(message, code: 'DATABASE_ERROR', originalError: originalError);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}

class NetworkException extends AppException {
  NetworkException(String message, {dynamic originalError})
      : super(message, code: 'NETWORK_ERROR', originalError: originalError);
}
