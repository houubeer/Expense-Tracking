import 'package:flutter/foundation.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Represents a reported error with full context
class ErrorReport {

  ErrorReport({
    required this.id,
    required this.timestamp,
    required this.message,
    this.error,
    this.stackTrace,
    this.severity = ErrorSeverity.medium,
    this.userId,
    this.screenName,
    this.context,
    this.handled = true,
  });
  final String id;
  final DateTime timestamp;
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final String? userId;
  final String? screenName;
  final Map<String, dynamic>? context;
  final bool handled;

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'message': message,
        'error': error?.toString(),
        'stackTrace': stackTrace?.toString(),
        'severity': severity.name,
        'userId': userId,
        'screenName': screenName,
        'context': context,
        'handled': handled,
      };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('====== ERROR REPORT ======');
    buffer.writeln('ID: $id');
    buffer.writeln(
        'Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp)}',);
    buffer.writeln('Severity: ${severity.name.toUpperCase()}');
    buffer.writeln('Message: $message');
    if (error != null) buffer.writeln('Error: $error');
    if (screenName != null) buffer.writeln('Screen: $screenName');
    if (userId != null) buffer.writeln('User ID: $userId');
    if (context != null) buffer.writeln('Context: $context');
    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace);
    }
    buffer.writeln('==========================');
    return buffer.toString();
  }
}

/// Service for tracking and reporting errors throughout the application
class ErrorReportingService extends ChangeNotifier {

  ErrorReportingService(this._logger);
  final LoggerService _logger;
  final List<ErrorReport> _errorHistory = [];
  final int _maxHistorySize = 100;
  File? _errorReportFile;

  /// Initialize error reporting
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final errorsDir = Directory(p.join(dir.path, 'error_reports'));
      if (!await errorsDir.exists()) {
        await errorsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _errorReportFile = File(p.join(errorsDir.path, 'errors_$timestamp.json'));

      _logger.info('ErrorReportingService initialized');
    } catch (e) {
      _logger.error('Failed to initialize error reporting', error: e);
    }
  }

  /// Report an error with full context
  Future<void> reportError(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.medium,
    String? userId,
    String? screenName,
    Map<String, dynamic>? context,
    bool handled = true,
  }) async {
    final report = ErrorReport(
      id: _generateErrorId(),
      timestamp: DateTime.now(),
      message: message,
      error: error,
      stackTrace: stackTrace ?? (error != null ? StackTrace.current : null),
      severity: severity,
      userId: userId,
      screenName: screenName,
      context: context,
      handled: handled,
    );

    // Add to history
    _errorHistory.add(report);
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }

    // Log based on severity
    switch (severity) {
      case ErrorSeverity.low:
        _logger.warning(message, error: error, stackTrace: stackTrace);
        break;
      case ErrorSeverity.medium:
        _logger.error(message, error: error, stackTrace: stackTrace);
        break;
      case ErrorSeverity.high:
      case ErrorSeverity.critical:
        _logger.fatal(message, error: error, stackTrace: stackTrace);
        break;
    }

    // Write to error report file
    await _writeErrorReport(report);

    // Notify listeners
    notifyListeners();
  }

  /// Report a database error
  Future<void> reportDatabaseError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      'Database Error: $operation',
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.high,
      context: {
        ...?context,
        'category': 'database',
        'operation': operation,
      },
    );
  }

  /// Report a UI error
  Future<void> reportUIError(
    String screen,
    String action,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      'UI Error: $action',
      error: error,
      stackTrace: stackTrace,
      screenName: screen,
      context: {
        ...?context,
        'category': 'ui',
        'action': action,
      },
    );
  }

  /// Report a business logic error
  Future<void> reportBusinessLogicError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      'Business Logic Error: $operation',
      error: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.high,
      context: {
        ...?context,
        'category': 'business_logic',
        'operation': operation,
      },
    );
  }

  /// Report a validation error
  Future<void> reportValidationError(
    String field,
    String validationMessage, {
    Map<String, dynamic>? context,
  }) async {
    await reportError(
      'Validation Error: $field - $validationMessage',
      severity: ErrorSeverity.low,
      context: {
        ...?context,
        'category': 'validation',
        'field': field,
      },
    );
  }

  /// Get error history
  List<ErrorReport> get errorHistory => List.unmodifiable(_errorHistory);

  /// Get errors by severity
  List<ErrorReport> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((e) => e.severity == severity).toList();
  }

  /// Get recent errors (last N)
  List<ErrorReport> getRecentErrors({int count = 10}) {
    final startIndex =
        _errorHistory.length > count ? _errorHistory.length - count : 0;
    return _errorHistory.sublist(startIndex);
  }

  /// Get errors by screen
  List<ErrorReport> getErrorsByScreen(String screenName) {
    return _errorHistory.where((e) => e.screenName == screenName).toList();
  }

  /// Get error statistics
  Map<String, dynamic> getErrorStatistics() {
    final stats = <String, dynamic>{
      'total': _errorHistory.length,
      'by_severity': <String, int>{},
      'by_screen': <String, int>{},
      'handled_vs_unhandled': {
        'handled': 0,
        'unhandled': 0,
      },
    };

    for (final error in _errorHistory) {
      // Count by severity
      stats['by_severity'][error.severity.name] =
          (stats['by_severity'][error.severity.name] ?? 0) + 1;

      // Count by screen
      if (error.screenName != null) {
        stats['by_screen'][error.screenName!] =
            (stats['by_screen'][error.screenName!] ?? 0) + 1;
      }

      // Count handled vs unhandled
      if (error.handled) {
        stats['handled_vs_unhandled']['handled']++;
      } else {
        stats['handled_vs_unhandled']['unhandled']++;
      }
    }

    return stats;
  }

  /// Clear error history
  void clearHistory() {
    _errorHistory.clear();
    notifyListeners();
  }

  /// Write error report to file
  Future<void> _writeErrorReport(ErrorReport report) async {
    if (_errorReportFile == null) return;

    try {
      final reportText = '${report.toString()}\n';
      await _errorReportFile!.writeAsString(
        reportText,
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      _logger.error('Failed to write error report to file', error: e);
    }
  }

  /// Generate unique error ID
  String _generateErrorId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_errorHistory.length}';
  }

  /// Get error reports directory
  Future<Directory?> getErrorReportsDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return Directory(p.join(dir.path, 'error_reports'));
    } catch (e) {
      return null;
    }
  }

  /// Export error history to file
  Future<File?> exportErrorHistory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final exportsDir = Directory(p.join(dir.path, 'exports'));
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final exportFile =
          File(p.join(exportsDir.path, 'error_export_$timestamp.txt'));

      final buffer = StringBuffer();
      buffer.writeln('========== ERROR HISTORY EXPORT ==========');
      buffer.writeln(
          'Export Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',);
      buffer.writeln('Total Errors: ${_errorHistory.length}');
      buffer.writeln('\nStatistics:');
      buffer.writeln(getErrorStatistics().toString());
      buffer.writeln('\n========== ERRORS ==========\n');

      for (final error in _errorHistory) {
        buffer.writeln(error.toString());
        buffer.writeln();
      }

      await exportFile.writeAsString(buffer.toString());
      _logger.info('Error history exported to: ${exportFile.path}');

      return exportFile;
    } catch (e) {
      _logger.error('Failed to export error history', error: e);
      return null;
    }
  }

  @override
  void dispose() {
    _errorHistory.clear();
    super.dispose();
  }
}
