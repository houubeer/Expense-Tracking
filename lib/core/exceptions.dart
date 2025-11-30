class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class DatabaseException extends AppException {
  DatabaseException(super.message,
      {super.originalError, super.code = 'DATABASE_ERROR'});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.code = 'VALIDATION_ERROR'});
}

class NetworkException extends AppException {
  NetworkException(super.message,
      {super.originalError, super.code = 'NETWORK_ERROR'});
}
