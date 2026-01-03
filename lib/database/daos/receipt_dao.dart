import 'package:drift/drift.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/tables/receipts_table.dart';

part 'receipt_dao.g.dart';

/// Data Access Object for Receipt operations
///
/// Provides optimized queries for managing multiple receipts per expense.
/// Follows the DAO pattern to encapsulate all database operations for receipts.
@DriftAccessor(tables: [Receipts])
class ReceiptDao extends DatabaseAccessor<AppDatabase> with _$ReceiptDaoMixin {
  ReceiptDao(AppDatabase db) : super(db);

  /// Watch all receipts for a specific expense
  ///
  /// Returns a stream that updates automatically when receipts change.
  /// Ordered by creation date (oldest first).
  ///
  /// [expenseId] The expense ID to get receipts for
  Stream<List<Receipt>> watchReceiptsForExpense(int expenseId) {
    return (select(receipts)
          ..where((r) => r.expenseId.equals(expenseId))
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
        .watch();
  }

  /// Get all receipts for a specific expense (one-time query)
  ///
  /// [expenseId] The expense ID to get receipts for
  Future<List<Receipt>> getReceiptsForExpense(int expenseId) async {
    return (select(receipts)
          ..where((r) => r.expenseId.equals(expenseId))
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
        .get();
  }

  /// Get a receipt by ID
  ///
  /// [receiptId] The receipt ID to get
  Future<Receipt?> getReceiptById(int receiptId) async {
    return (select(receipts)..where((r) => r.id.equals(receiptId)))
        .getSingleOrNull();
  }

  /// Insert a single receipt
  ///
  /// Returns the inserted receipt's ID
  Future<int> insertReceipt(ReceiptsCompanion receipt) async {
    return into(receipts).insert(receipt);
  }

  /// Insert multiple receipts
  ///
  /// Returns list of inserted receipt IDs
  Future<List<int>> insertMultipleReceipts(List<ReceiptsCompanion> receiptList) async {
    final ids = <int>[];
    for (final receipt in receiptList) {
      final id = await into(receipts).insert(receipt);
      ids.add(id);
    }
    return ids;
  }

  /// Batch insert for better performance
  Future<void> batchInsertReceipts(List<ReceiptsCompanion> receiptList) async {
    await batch((batch) {
      batch.insertAll(receipts, receiptList);
    });
  }

  /// Update a receipt
  Future<bool> updateReceipt(Receipt receipt) async {
    return update(receipts).replace(receipt);
  }

  /// Mark receipt as uploaded
  ///
  /// [receiptId] The receipt ID to update
  /// [remoteUrl] The remote storage URL
  Future<int> markReceiptAsUploaded(int receiptId, String remoteUrl) async {
    return (update(receipts)..where((r) => r.id.equals(receiptId))).write(
      ReceiptsCompanion(
        remoteUrl: Value(remoteUrl),
        uploadStatus: const Value('uploaded'),
        uploadedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Delete a receipt by ID
  ///
  /// [receiptId] The receipt ID to delete
  Future<int> deleteReceipt(int receiptId) async {
    return (delete(receipts)..where((r) => r.id.equals(receiptId))).go();
  }

  /// Delete all receipts for an expense
  ///
  /// [expenseId] The expense ID whose receipts to delete
  /// Note: Database has CASCADE DELETE, so this is called automatically
  /// when parent expense is deleted. Kept for explicit operations.
  Future<int> deleteReceiptsForExpense(int expenseId) async {
    return (delete(receipts)..where((r) => r.expenseId.equals(expenseId)))
        .go();
  }

  /// Get count of receipts for an expense
  ///
  /// [expenseId] The expense ID to count receipts for
  Future<int> getReceiptCount(int expenseId) async {
    final query = selectOnly(receipts)
      ..addColumns([receipts.id.count()])
      ..where(receipts.expenseId.equals(expenseId));

    final result = await query.getSingle();
    return result.read(receipts.id.count()) ?? 0;
  }

  /// Get pending uploads (for background sync)
  Future<List<Receipt>> getPendingUploads() async {
    return (select(receipts)
          ..where((r) => r.uploadStatus.equals('local').not())
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
        .get();
  }
}
