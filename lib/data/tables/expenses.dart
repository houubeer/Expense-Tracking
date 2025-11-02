import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 3, max: 100)();

  RealColumn get amount => real()();

  IntColumn get categoryId =>
      integer().customConstraint('REFERENCES categories(id) ON DELETE CASCADE')();

  DateTimeColumn get date => dateTime()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().nullable()();
}
