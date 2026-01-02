import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/tables/categories_table.dart';

/// Expenses table with optimized indexes for common query patterns
@TableIndex(name: 'idx_expenses_date', columns: {#date})
@TableIndex(name: 'idx_expenses_category', columns: {#categoryId})
@TableIndex(name: 'idx_expenses_date_category', columns: {#date, #categoryId})
@TableIndex(name: 'idx_expenses_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_expenses_reimbursable', columns: {#isReimbursable})
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Flag to mark expense as reimbursable (employee-owed expense)
  BoolColumn get isReimbursable =>
      boolean().withDefault(const Constant(false))();

  /// Path to attached receipt image or PDF file (nullable)
  TextColumn get receiptPath => text().nullable()();

  // Sync-related columns
  TextColumn get organizationId => text().nullable()(); // UUID from Supabase
  TextColumn get userId => text().nullable()(); // UUID of creator from Supabase
  IntColumn get serverId => integer().nullable()(); // ID from Supabase server
  TextColumn get receiptUrl => text().nullable()(); // Supabase Storage URL
  IntColumn get version =>
      integer().withDefault(const Constant(0))(); // For conflict resolution
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
