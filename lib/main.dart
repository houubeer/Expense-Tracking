import 'package:expense_tracking_desktop_app/app.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  runApp(ExpenseTrackerApp(database: database));
}
