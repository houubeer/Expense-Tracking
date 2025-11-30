import 'package:drift/drift.dart';

/// Categories table with optimized indexes for common query patterns
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

  @override
  List<String> get customConstraints => [
        'CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name)',
        'CREATE INDEX IF NOT EXISTS idx_categories_budget ON categories(budget)',
        'CREATE INDEX IF NOT EXISTS idx_categories_budget_spent ON categories(budget, spent)',
      ];
}
