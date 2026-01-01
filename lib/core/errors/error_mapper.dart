import 'package:expense_tracking_desktop_app/core/exceptions.dart';

/// Maps technical errors to user-friendly messages
class ErrorMapper {
  ErrorMapper._();

  /// Converts technical errors to user-friendly messages
  ///
  /// [error] The error to map
  /// Returns a user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DatabaseException) {
      return _mapDatabaseException(error);
    }

    if (error is ValidationException) {
      // Validation messages are already user-friendly
      return error.message;
    }

    if (error is NetworkException) {
      return 'Network connection issue. Please check your internet connection.';
    }

    // Handle string error messages
    if (error is String) {
      return _mapStringError(error);
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  /// Maps database exceptions to user-friendly messages
  static String _mapDatabaseException(DatabaseException error) {
    final message = error.message.toLowerCase();

    // UNIQUE constraint violation
    if (message.contains('unique constraint') || message.contains('unique')) {
      if (message.contains('name')) {
        return 'An item with this name already exists. Please use a different name.';
      }
      return 'This item already exists. Please try a different value.';
    }

    // Database locked
    if (message.contains('database is locked') || message.contains('locked')) {
      return 'The app is busy processing another request. Please try again in a moment.';
    }

    // FOREIGN KEY constraint violation
    if (message.contains('foreign key constraint') ||
        message.contains('foreign key')) {
      return 'Cannot delete this item because it is being used elsewhere. Please remove related items first.';
    }

    // NOT NULL constraint
    if (message.contains('not null constraint') ||
        message.contains('not null')) {
      return 'Required information is missing. Please fill in all required fields.';
    }

    // Disk I/O error
    if (message.contains('disk i/o') || message.contains('io error')) {
      return 'Unable to save changes. Please check available disk space.';
    }

    // Corruption
    if (message.contains('corrupt') || message.contains('malformed')) {
      return 'Data corruption detected. Please restart the app or contact support.';
    }

    // Generic database error
    return 'Unable to save your changes. Please try again.';
  }

  /// Maps string error messages
  static String _mapStringError(String error) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('connection') || lowerError.contains('network')) {
      return 'Connection issue. Please check your network.';
    }

    if (lowerError.contains('timeout')) {
      return 'The operation took too long. Please try again.';
    }

    if (lowerError.contains('permission') || lowerError.contains('denied')) {
      return 'Permission denied. Please check app permissions.';
    }

    return error; // Return as-is if no mapping found
  }

  /// Provides actionable help text based on the error type
  ///
  /// [error] The error to analyze
  /// Returns helpful guidance for the user
  static String getActionableHelp(dynamic error) {
    if (error is DatabaseException) {
      final message = error.message.toLowerCase();

      if (message.contains('locked')) {
        return 'Wait a few seconds and try again. Close any other operations in progress.';
      }

      if (message.contains('corrupt') || message.contains('malformed')) {
        return 'Try restarting the app. If the problem persists, you may need to restore from a backup.';
      }

      if (message.contains('disk')) {
        return 'Free up some disk space and try again.';
      }

      if (message.contains('foreign key')) {
        return 'Delete or reassign related expenses before deleting this category.';
      }

      return 'If this problem persists, try restarting the app.';
    }

    if (error is NetworkException) {
      return 'Check your internet connection and try again.';
    }

    // Generic help
    return 'If you continue to experience issues, please contact support.';
  }

  /// Gets a short error code for logging/support purposes
  ///
  /// [error] The error to encode
  /// Returns a short error code
  static String getErrorCode(dynamic error) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (error is DatabaseException) {
      return 'DB-$timestamp';
    }

    if (error is ValidationException) {
      return 'VAL-$timestamp';
    }

    if (error is NetworkException) {
      return 'NET-$timestamp';
    }

    return 'ERR-$timestamp';
  }

  /// Determines if an error should be reported to error tracking
  ///
  /// [error] The error to evaluate
  /// Returns true if the error should be reported
  static bool shouldReportError(dynamic error) {
    // Don't report validation errors (user input issues)
    if (error is ValidationException) {
      return false;
    }

    // Don't report expected database errors
    if (error is DatabaseException) {
      final message = error.message.toLowerCase();
      if (message.contains('unique constraint')) {
        return false; // User tried to create duplicate
      }
    }

    // Report everything else
    return true;
  }
}
