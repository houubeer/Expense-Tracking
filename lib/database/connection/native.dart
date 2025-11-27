import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

LazyDatabase connect() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dir.path, 'expense_tracker.sqlite'));
    return NativeDatabase(dbFile);
  });
}
