import 'package:drift/drift.dart';

/// Categories table with optimized indexes for common query patterns
@TableIndex(name: 'idx_categories_name', columns: {#name})
@TableIndex(name: 'idx_categories_budget', columns: {#budget})
@TableIndex(name: 'idx_categories_budget_spent', columns: {#budget, #spent})
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get color => integer()();
  TextColumn get iconCodePoint => text()();
  RealColumn get budget => real().withDefault(const Constant(0.0))();
  RealColumn get spent => real().withDefault(const Constant(0.0))();
  IntColumn get version =>
      integer().withDefault(const Constant(0))(); // For optimistic locking
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Sync-related columns
  TextColumn get organizationId => text().nullable()(); // UUID from Supabase
  TextColumn get userId => text().nullable()(); // UUID of creator from Supabase
  IntColumn get serverId => integer().nullable()(); // ID from Supabase server
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
