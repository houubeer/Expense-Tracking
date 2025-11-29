import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;
import 'package:expense_tracking_desktop_app/database/i_database.dart';
// Import tables and DAOs
import 'tables/categories_table.dart';
import 'tables/expenses_table.dart';
import 'daos/category_dao.dart';
import 'daos/expense_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, Expenses],
  daos: [CategoryDao, ExpenseDao],
)
class AppDatabase extends _$AppDatabase implements IDatabase {
  AppDatabase() : super(impl.connect());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Add categories table
            await m.createTable(categories);
          }
          if (from < 3) {
            // Add spent column to categories
            await m.addColumn(categories, categories.spent);
          }
          if (from < 4) {
            // Add expenses table
            await m.createTable(expenses);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  @override
  Future<T> transaction<T>(Future<T> Function() action,
      {bool requireNew = false}) async {
    return await super.transaction(action, requireNew: requireNew);
  }
}
