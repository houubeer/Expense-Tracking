import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
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
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'expense_tracker.sqlite'));
    return NativeDatabase(dbFile);
  });
}
