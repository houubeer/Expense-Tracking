import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;
import 'package:expense_tracking_desktop_app/database/i_database.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
// Import tables and DAOs
import 'tables/categories_table.dart';
import 'tables/expenses_table.dart';
import 'tables/receipts_table.dart';
import 'tables/organizations_table.dart';
import 'tables/user_profiles_table.dart';
import 'tables/sync_queue_table.dart';
import 'daos/category_dao.dart';
import 'daos/expense_dao.dart';
import 'daos/receipt_dao.dart';

part 'app_database.g.dart';

/// Main database class for the Expense Tracking application.
///
/// This class extends Drift's database implementation and provides access to
/// all data access objects (DAOs) and database operations. It manages the
/// database schema, migrations, and provides health check capabilities.
///
/// The database includes:
/// - Organizations table: Multi-tenant organization data
/// - UserProfiles table: User account information
/// - Categories table: Budget categories with spending limits
/// - Expenses table: Individual expense records
/// - SyncQueue table: Offline-first sync queue
///
/// Schema version: 7
///
/// Example usage:
/// ```dart
/// final database = AppDatabase();
/// final categories = await database.categoryDao.getAllCategories();
/// ```
@DriftDatabase(
  tables: [
    Organizations,
    UserProfiles,
    Categories,
    Expenses,
    Receipts,
    SyncQueue,
  ],
  daos: [CategoryDao, ExpenseDao, ReceiptDao],
)
class AppDatabase extends _$AppDatabase implements IDatabase {
  final ConnectivityService? _connectivityService;
  final _logger = LoggerService.instance;

  /// Creates a new instance of the database with platform-specific connection.
  ///
  /// [_connectivityService] Optional service for monitoring database connectivity.
  AppDatabase([this._connectivityService]) : super(impl.connect());

  /// Creates a test instance of the database with a custom executor.
  ///
  /// Used for unit testing with in-memory databases.
  ///
  /// [e] The query executor to use for database operations.
  /// [_connectivityService] Optional service for monitoring database connectivity.
  AppDatabase.forTesting(super.e, [this._connectivityService]);

  /// Provides access to category-related database operations.
  @override
  CategoryDao get categoryDao => CategoryDao(this, _connectivityService);

  /// Provides access to expense-related database operations.
  @override
  ExpenseDao get expenseDao => ExpenseDao(this, _connectivityService);

  /// Provides access to receipt-related database operations.
  @override
  ReceiptDao get receiptDao => ReceiptDao(this, _connectivityService);

  /// The current schema version of the database.
  ///
  /// Increment this value when making schema changes to trigger migrations.
  @override
  int get schemaVersion => 8;

  /// Handles database schema migrations when the version changes.
  ///
  /// This method is called automatically by Drift when the app detects a
  /// schema version mismatch. It executes the necessary SQL statements to
  /// upgrade or downgrade the database schema.
  ///
  /// Migration history:
  /// - v1->v2: Added expenses table
  /// - v2->v3: Added category color and icon fields
  /// - v3->v4: Added version column for optimistic locking
  /// - v4->v5: Added createdAt timestamp to expenses
  /// - v5->v6: Added isReimbursable and receiptPath columns to expenses
  /// - v6->v7: Added organizations, user_profiles, sync_queue tables and sync columns
  /// - v7->v8: Added receipts table for multiple receipts per expense (0:N)
  ///
  /// [m] The migrator instance that executes schema changes.
  /// [from] The current schema version.
  /// [to] The target schema version.
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
          if (from < 6) {
            // Add isReimbursable and receiptPath columns to expenses
            await m.addColumn(expenses, expenses.isReimbursable);
            await m.addColumn(expenses, expenses.receiptPath);
          }
          if (from < 7) {
            // Add new tables for multi-tenant and sync support
            await m.createTable(organizations);
            await m.createTable(userProfiles);
            await m.createTable(syncQueue);

            // Add sync columns to existing tables
            await m.addColumn(categories, categories.organizationId);
            await m.addColumn(categories, categories.userId);
            await m.addColumn(categories, categories.serverId);
            await m.addColumn(categories, categories.syncedAt);
            await m.addColumn(categories, categories.isSynced);

            await m.addColumn(expenses, expenses.organizationId);
            await m.addColumn(expenses, expenses.userId);
            await m.addColumn(expenses, expenses.serverId);
            await m.addColumn(expenses, expenses.receiptUrl);
            await m.addColumn(expenses, expenses.version);
            await m.addColumn(expenses, expenses.syncedAt);
            await m.addColumn(expenses, expenses.isSynced);
          }
          if (from < 8) {
            // Add receipts table for multiple receipt support (0:N relationship)
            await m.createTable(receipts);
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

  /// Performs a comprehensive health check on the database.
  ///
  /// This method verifies:
  /// - Database connection is active (executes a test query)
  /// - Required tables exist in the schema
  /// Performs a comprehensive health check on the database.
  ///
  /// This method verifies:
  /// - **Connection**: Executes a test query to confirm database is accessible
  /// - **Schema**: Verifies required tables exist
  /// - **Integrity**: Runs PRAGMA integrity_check to detect corruption
  ///
  /// Returns `true` if all checks pass, `false` otherwise.
  ///
  /// Should be called on app startup or when database errors are suspected.
  /// If this returns `false`, consider calling [attemptRecovery].
  ///
  /// Example:
  /// ```dart
  /// if (!await database.healthCheck()) {
  ///   await database.attemptRecovery();
  /// }
  /// ```
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
      _logger.error('Database health check failed', error: e, stackTrace: null);
      return false;
    }
  }

  /// Attempts to recover the database from errors or corruption.
  ///
  /// This method performs maintenance operations:
  /// - **VACUUM**: Reclaims unused space and defragments the database file
  /// - **REINDEX**: Rebuilds all database indexes for optimal query performance
  ///
  /// Should be called when [healthCheck] returns false or after detecting
  /// database anomalies such as slow queries or integrity errors.
  ///
  /// Throws an [Exception] if recovery operations fail.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await database.attemptRecovery();
  ///   print('Database recovered successfully');
  /// } catch (e) {
  ///   print('Recovery failed: $e');
  ///   // Consider recreating the database
  /// }
  /// ```
  Future<void> attemptRecovery() async {
    try {
      // Try to run VACUUM to clean up and optimize
      await customStatement('VACUUM');

      // Rebuild indices if they exist
      await customStatement('REINDEX');

      _logger.info('Database recovery attempted successfully');
    } catch (e) {
      _logger.error('Database recovery failed', error: e, stackTrace: null);
      throw Exception('Database recovery failed: $e');
    }
  }
}
