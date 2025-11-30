import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

LazyDatabase connect() {
  return LazyDatabase(() async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dir.path, 'expense_tracker.sqlite'));

        // Check if database file is accessible
        if (dbFile.existsSync()) {
          // Verify database is not corrupt
          try {
            final db = sqlite3.open(dbFile.path);
            try {
              // Run integrity check
              final result = db.select('PRAGMA integrity_check');
              if (result.isEmpty || result.first['integrity_check'] != 'ok') {
                throw Exception('Database integrity check failed');
              }
            } finally {
              db.dispose();
            }
          } catch (e) {
            // Database is corrupt, create backup and recreate
            print('Database corruption detected: $e');
            final backupPath =
                '${dbFile.path}.corrupt.${DateTime.now().millisecondsSinceEpoch}';
            await dbFile.copy(backupPath);
            await dbFile.delete();
            print('Corrupt database backed up to: $backupPath');
          }
        }

        return NativeDatabase(dbFile);
      } catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception(
              'Failed to connect to database after $maxRetries attempts: $e');
        }
        print(
            'Database connection attempt ${attempt + 1} failed: $e. Retrying...');
        await Future.delayed(retryDelay);
      }
    }

    throw Exception('Failed to establish database connection');
  });
}
