import 'package:drift/drift.dart';
import 'categories_table.dart';

class BudgetAlerts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get alertType =>
      text().withLength(min: 1, max: 50)(); // 'warning', 'critical', 'exceeded'
  TextColumn get message => text().withLength(min: 1, max: 500)();
  RealColumn get percentage => real()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
