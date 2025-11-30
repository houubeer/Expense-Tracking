import 'package:expense_tracking_desktop_app/app.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppDatabase? database;
  final connectivityService = ConnectivityService();

  try {
    database = AppDatabase(connectivityService);

    // Set up health check callback for reconnection attempts
    connectivityService.healthCheckCallback = () async {
      try {
        return await database!.healthCheck();
      } catch (e) {
        return false;
      }
    };

    // Verify database connection with a simple query
    await database.customSelect('SELECT 1').get();

    print('Database connection established successfully');
    connectivityService.markSuccessfulOperation();
  } catch (e) {
    print('FATAL: Failed to initialize database: $e');
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

  runApp(ExpenseTrackerApp(
    database: database,
    connectivityService: connectivityService,
  ));
}
