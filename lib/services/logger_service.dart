import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Centralized logging service for the application
/// Provides structured logging with different levels and log persistence
class LoggerService {
  static LoggerService? _instance;
  late Logger _logger;
  late File? _logFile;
  bool _isInitialized = false;

  LoggerService._();

  /// Get singleton instance of LoggerService
  static LoggerService get instance {
    _instance ??= LoggerService._();
    return _instance!;
  }

  /// Initialize the logger with file output
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get log file path
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory(p.join(dir.path, 'logs'));
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File(p.join(logsDir.path, 'app_log_$timestamp.txt'));

      // Configure logger
      _logger = Logger(
        filter: ProductionFilter(),
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: MultiOutput([
          ConsoleOutput(),
          FileOutput(file: _logFile!),
        ]),
      );

      _isInitialized = true;
      _logger.i('LoggerService initialized successfully');
    } catch (e) {
      // Fallback to console-only logger if file initialization fails
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      _logger.w('Failed to initialize file logging, using console only: $e');
      _isInitialized = true;
    }
  }

  /// Log debug message
  void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log fatal/critical error message
  void fatal(String message, {dynamic error, StackTrace? stackTrace}) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log with custom level and structured data
  void log(
    Level level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _ensureInitialized();
    final enrichedMessage =
        data != null ? '$message | Data: ${data.toString()}' : message;
    _logger.log(level, enrichedMessage, error: error, stackTrace: stackTrace);
  }

  /// Ensure logger is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized) {
      // Use synchronous console-only logger as emergency fallback
      _logger = Logger(
        printer: SimplePrinter(),
      );
      print('WARNING: LoggerService used before initialization');
    }
  }

  /// Close logger and cleanup resources
  Future<void> close() async {
    _logger.close();
    _isInitialized = false;
  }

  /// Get current log file path (if available)
  String? get logFilePath => _logFile?.path;

  /// Get logs directory
  Future<Directory?> getLogsDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return Directory(p.join(dir.path, 'logs'));
    } catch (e) {
      return null;
    }
  }

  /// Delete old log files (keep last N days)
  Future<void> cleanOldLogs({int keepDays = 7}) async {
    try {
      final logsDir = await getLogsDirectory();
      if (logsDir == null || !await logsDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      final files = await logsDir.list().toList();

      for (var entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            info('Deleted old log file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      error('Failed to clean old logs', error: e);
    }
  }
}

/// Custom file output for logger
class FileOutput extends LogOutput {
  final File file;

  FileOutput({required this.file});

  @override
  void output(OutputEvent event) {
    try {
      final buffer = StringBuffer();
      for (var line in event.lines) {
        buffer.writeln(line);
      }
      file.writeAsStringSync(
        buffer.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      print('Error writing to log file: $e');
    }
  }
}

/// Multiple outputs wrapper
class MultiOutput extends LogOutput {
  final List<LogOutput> outputs;

  MultiOutput(this.outputs);

  @override
  void output(OutputEvent event) {
    for (var output in outputs) {
      try {
        output.output(event);
      } catch (e) {
        print('Error in log output: $e');
      }
    }
  }
}
