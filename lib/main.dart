import 'package:expense_tracking_desktop_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:drift/drift.dart';

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
    // Seed with sample categories from screenshots
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Food',
        color: 0xFFF97316, // Orange
        iconCodePoint: '${Icons.fastfood.codePoint}',
        budget: const Value(500.00),
      ),
    );
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Transport',
        color: 0xFFEC4899, // Pink
        iconCodePoint: '${Icons.directions_car.codePoint}',
        budget: const Value(300.00),
      ),
    );
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Utilities',
        color: 0xFFFBBF24, // Yellow
        iconCodePoint: '${Icons.lightbulb.codePoint}',
        budget: const Value(200.00),
      ),
    );
  }
}
