import 'package:drift/drift.dart';

/// Local sync queue for offline-first operations
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// UUID for the sync operation
  TextColumn get syncId => text().unique()();

  TextColumn get tableName => text()();
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

  @override
  List<String> get customConstraints => [
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_synced ON sync_queue(synced)',
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_created ON sync_queue(created_at)',
        'CREATE INDEX IF NOT EXISTS idx_sync_queue_table ON sync_queue(table_name)',
      ];
}
