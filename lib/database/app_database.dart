import 'dart:io'; // For file operations (creating the SQLite file on disk).
import 'package:drift/drift.dart'; // Core Drift package — lets you define tables, DAOs, queries, etc.
import 'package:path_provider/path_provider.dart'; // Finds safe folders on the device (like Documents).
import 'package:drift/native.dart';
import 'package:path/path.dart'
    as p; // To join paths in a platform-safe way (p.join = correct slashes for Windows/Linux/macOS).
// Import tables and DAOs
import 'tables/example_table.dart';
import 'daos/example_dao.dart';

part 'app_database.g.dart'; // generated file

@DriftDatabase(
  tables: [ExampleTable],
  daos: [ExampleDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  MigrationStrategy get migrationStrategy => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {},
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'expense_tracker.sqlite'));
    return NativeDatabase(dbFile);
  });
}
