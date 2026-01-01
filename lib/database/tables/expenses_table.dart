import 'package:drift/drift.dart';
import 'categories_table.dart';

/// Expenses table with optimized indexes for common query patterns
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

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE',
        'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date)',
        'CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category_id)',
        'CREATE INDEX IF NOT EXISTS idx_expenses_date_category ON expenses(date, category_id)',
        'CREATE INDEX IF NOT EXISTS idx_expenses_created_at ON expenses(created_at)',
        'CREATE INDEX IF NOT EXISTS idx_expenses_reimbursable ON expenses(is_reimbursable)',
      ];
}
