import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

/// Data Access Object for managing sync queue operations
///
/// Handles offline-first sync queue for pending changes
@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Get all pending (unsynced) items ordered by creation time
  Future<List<SyncQueueData>> getPendingItems() async {
    return (select(syncQueue)
          ..where((q) => q.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Watch pending items count
  Stream<int> watchPendingCount() {
    final countExp = syncQueue.id.count();
    final query = selectOnly(syncQueue)
      ..addColumns([countExp])
      ..where(syncQueue.synced.equals(false));
    return query.map((row) => row.read(countExp) ?? 0).watchSingle();
  }

  /// Add item to sync queue
  Future<int> addToQueue({
    required String syncId,
    required String targetTable,
    required int? recordId,
    required String operation,
    required String payload,
  }) async {
    return into(syncQueue).insert(SyncQueueCompanion(
      syncId: Value(syncId),
      targetTable: Value(targetTable),
      recordId: Value(recordId),
      operation: Value(operation),
      payload: Value(payload),
      synced: const Value(false),
      retryCount: const Value(0),
    ));
  }

  /// Mark item as synced
  Future<void> markSynced(int id) async {
    await (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        synced: const Value(true),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark item as failed with error
  Future<void> markFailed(int id, String error) async {
    final item = await (select(syncQueue)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    if (item != null) {
      await (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(
          error: Value(error),
          retryCount: Value(item.retryCount + 1),
        ),
      );
    }
  }

  /// Get items that failed and can be retried (max 5 retries)
  Future<List<SyncQueueData>> getRetryableItems() async {
    return (select(syncQueue)
          ..where((q) =>
              q.synced.equals(false) &
              q.error.isNotNull() &
              q.retryCount.isSmallerThanValue(5))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Delete synced items older than specified duration
  Future<int> cleanupSyncedItems({Duration olderThan = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().subtract(olderThan);
    return (delete(syncQueue)
          ..where((q) =>
              q.synced.equals(true) & q.syncedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Delete all synced items
  Future<int> deleteAllSynced() async {
    return (delete(syncQueue)..where((q) => q.synced.equals(true))).go();
  }

  /// Get queue item by sync ID
  Future<SyncQueueData?> getBySyncId(String syncId) async {
    return (select(syncQueue)..where((q) => q.syncId.equals(syncId)))
        .getSingleOrNull();
  }

  /// Remove item from queue
  Future<void> removeItem(int id) async {
    await (delete(syncQueue)..where((q) => q.id.equals(id))).go();
  }

  /// Check if there are pending items for a specific table and record
  Future<bool> hasPendingForRecord(String targetTable, int recordId) async {
    final count = await (select(syncQueue)
          ..where((q) =>
              q.targetTable.equals(targetTable) &
              q.recordId.equals(recordId) &
              q.synced.equals(false)))
        .get();
    return count.isNotEmpty;
  }
}
