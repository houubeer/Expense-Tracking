import 'package:expense_tracking_desktop_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/seeds/budget_dummy_data.dart';

late AppDatabase database;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database = AppDatabase();
  await _seedDatabase();
  runApp(const ExpenseTrackerApp());
}

Future<void> _seedDatabase() async {
  final categories = await database.categoryDao.getAllCategories();
  if (categories.isEmpty) {
    // Use dummy data for testing
    await BudgetDummyData.seedDummyData(database);
  }
}
