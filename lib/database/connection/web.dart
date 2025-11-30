import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

LazyDatabase connect() {
  return LazyDatabase(() async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final result = await WasmDatabase.open(
          databaseName: 'expense_tracker',
          sqlite3Uri: Uri.parse('sqlite3.wasm'),
          driftWorkerUri: Uri.parse('drift_worker.js'),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Database connection timeout after 10 seconds');
          },
        );

        if (result.missingFeatures.isNotEmpty) {
          // Log warning about missing features
          print('Using ${result.chosenImplementation} due to missing features: '
              '${result.missingFeatures}');
        }

        return result.resolvedExecutor;
      } catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception(
              'Failed to connect to web database after $maxRetries attempts: $e');
        }
        print(
            'Web database connection attempt ${attempt + 1} failed: $e. Retrying...');
        await Future.delayed(retryDelay);
      }
    }

    throw Exception('Failed to establish web database connection');
  });
}
