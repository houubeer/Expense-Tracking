import 'package:expense_tracking_desktop_app/app.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging service first
  final logger = LoggerService.instance;
  await logger.initialize();
  logger.info('Application starting...');

  // Initialize error reporting service
  final errorReporting = ErrorReportingService(logger);
  await errorReporting.initialize();

  // Clean old logs (keep last 7 days)
  await logger.cleanOldLogs(keepDays: 7);

  AppDatabase? database;
  final connectivityService = ConnectivityService();

  try {
    logger.info('Initializing database connection...');
    database = AppDatabase(connectivityService);

    // Set up health check callback for reconnection attempts
    connectivityService.healthCheckCallback = () async {
      try {
        return await database!.healthCheck();
      } catch (e) {
        logger.error('Health check failed', error: e);
        return false;
      }
    };

    // Verify database connection with a simple query
    await database.customSelect('SELECT 1').get();

    logger.info('Database connection established successfully');
    connectivityService.markSuccessfulOperation();
  } catch (e, stackTrace) {
    logger.fatal('FATAL: Failed to initialize database',
        error: e, stackTrace: stackTrace);
    await errorReporting.reportError(
      'Fatal database initialization error',
      error: e,
      stackTrace: stackTrace,
      severity: ErrorSeverity.critical,
      handled: false,
    );
    connectivityService.handleConnectionFailure(e.toString());

    // Show error dialog and exit
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Database Connection Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Failed to connect to the database.\\n\\n$e',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // User can try to restart the app
                  },
                  child: const Text('Contact Support'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return;
  }

  logger.info('Launching application UI...');
  runApp(ExpenseTrackerApp(
    database: database,
    connectivityService: connectivityService,
    errorReportingService: errorReporting,
  ));
}
