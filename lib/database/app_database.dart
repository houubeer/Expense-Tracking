import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;
import 'package:expense_tracking_desktop_app/database/i_database.dart';
// Import tables and DAOs
import 'tables/categories_table.dart';
import 'tables/expenses_table.dart';
import 'daos/category_dao.dart';
import 'daos/expense_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Expenses],
  daos: [CategoryDao, ExpenseDao],
)
class AppDatabase extends _$AppDatabase implements IDatabase {
  AppDatabase() : super(_createConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  static QueryExecutor _createConnection() {
    try {
      return impl.connect();
    } catch (e) {
      throw Exception('Failed to initialize database connection: $e');
    }
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Add categories table
            await m.createTable(categories);
          }
          if (from < 3) {
            // Add spent column to categories
            await m.addColumn(categories, categories.spent);
          }
          if (from < 4) {
            // Add expenses table
            await m.createTable(expenses);
          }
          if (from < 5) {
            // Add version column to categories for optimistic locking
            await m.addColumn(categories, categories.version);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  @override
  Future<T> transaction<T>(Future<T> Function() action,
      {bool requireNew = false}) async {
    return await super.transaction(action, requireNew: requireNew);
  }

  /// Health check to verify database connection and integrity
  Future<bool> healthCheck() async {
    try {
      // Test basic query execution
      await customSelect('SELECT 1').get();

      // Verify tables exist
      final tables = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table'",
      ).get();

      if (tables.isEmpty) {
        throw Exception('No tables found in database');
      }

      // Run integrity check
      final integrity = await customSelect('PRAGMA integrity_check').get();
      if (integrity.isEmpty ||
          integrity.first.data['integrity_check'] != 'ok') {
        throw Exception('Database integrity check failed');
      }

      return true;
    } catch (e) {
      print('Database health check failed: $e');
      return false;
    }
  }

  /// Attempt to recover from database errors
  Future<void> attemptRecovery() async {
    try {
      // Try to run VACUUM to clean up and optimize
      await customStatement('VACUUM');

      // Rebuild indices if they exist
      await customStatement('REINDEX');

      print('Database recovery attempted successfully');
    } catch (e) {
      throw Exception('Database recovery failed: $e');
    }
  }
}
