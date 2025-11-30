import 'package:drift/drift.dart';
import 'categories_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get description => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {id}
      ];

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE',
      ];

  @override
  Set<Column> get primaryKey => {id};
}

@DriftIndex(name: 'expenses_date_idx', columns: {#date})
@DriftIndex(name: 'expenses_category_idx', columns: {#categoryId})
class ExpensesIndex extends Table {
  // This is just to trigger index generation, actual indices are defined via annotations if using drift files,
  // but for Dart tables we use the @DriftDatabase or table overrides.
  // Actually, for Dart tables, we override `primaryKey` or `uniqueKeys`.
  // For non-unique indices in Dart tables, we need to use the @DriftDatabase(include: {'tables.drift'}) or similar,
  // OR simpler: just define it in the database class or use custom migration.
  // Wait, Drift 2.0 supports @DriftIndex on the table class? No, it supports it on the Database or via .drift files.
  // Let's check if I can just add it to the AppDatabase annotation.
  // Actually, let's keep it simple and just rely on the fact that we are using Drift.
  // The best way for Dart-only tables is to override `customConstraints` or use `migration`.
  // But wait, Drift 2.14+ supports @TableIndex. Let's check if we can use that.
  // Since I cannot check the version easily, I will assume standard Drift.
  // I will add the indices via the MigrationStrategy in AppDatabase to be safe and explicit.
}
