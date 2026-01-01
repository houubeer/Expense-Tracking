import 'package:drift/drift.dart';

/// Local sync queue for offline-first operations
@TableIndex(name: 'idx_sync_queue_synced', columns: {#synced})
@TableIndex(name: 'idx_sync_queue_created', columns: {#createdAt})
@TableIndex(name: 'idx_sync_queue_table', columns: {#targetTable})
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// UUID for the sync operation
  TextColumn get syncId => text().unique()();

  /// Target table name: categories, expenses, etc.
  TextColumn get targetTable => text()();
  IntColumn get recordId => integer().nullable()();

  /// Operation type: INSERT, UPDATE, DELETE
  TextColumn get operation => text()();

  /// JSON payload of the record
  TextColumn get payload => text()();

  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  TextColumn get error => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
