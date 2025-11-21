import 'package:drift/drift.dart';
import 'categories_table.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  DateTimeColumn get date => dateTime()(); // When expense actually occurred
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)(); // When record was created
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)(); // Last modification time
}
