import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/example_table.dart';
// This line tells Drift to generate the code for this DAO
part 'example_dao.g.dart';

@DriftAccessor(tables: [ExampleTable])
class ExampleDao extends DatabaseAccessor<AppDatabase> with _$ExampleDaoMixin {
  ExampleDao(super.db);

  // INSERT new example row
  Future<int> insertExample(ExampleTableCompanion entry) =>
      into(exampleTable).insert(entry);

  // SELECT all examples
  Future<List<ExampleTableData>> getAllExamples() => select(exampleTable).get();

  // DELETE an example by id
  Future<int> deleteExample(int id) =>
      (delete(exampleTable)..where((tbl) => tbl.id.equals(id))).go();

  // UPDATE an example entry
  Future<bool> updateExample(ExampleTableCompanion entry) =>
      update(exampleTable).replace(entry);
}
