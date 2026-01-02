import 'package:drift/drift.dart';
import 'expenses_table.dart';

/// Receipts table - supports multiple receipts per expense (0:N relationship)
/// Allows users to attach multiple receipt images/PDFs to a single expense
class Receipts extends Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to expenses table
  IntColumn get expenseId => integer().references(Expenses, #id,
      onDelete: KeyAction.cascade)();

  /// Local file path (for offline support)
  TextColumn get localPath => text().nullable()();

  /// Remote URL (Supabase Storage URL after upload)
  TextColumn get remoteUrl => text().nullable()();

  /// Original filename
  TextColumn get fileName => text()();

  /// File type (jpg, png, pdf, etc.)
  TextColumn get fileType => text()();

  /// File size in bytes
  IntColumn get fileSize => integer().nullable()();

  /// Upload status: 'local', 'uploading', 'uploaded', 'failed'
  TextColumn get uploadStatus =>
      text().withDefault(const Constant('local'))();

  /// Timestamp when receipt was added
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when successfully uploaded to remote storage
  DateTimeColumn get uploadedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE',
      ];
}
