import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Dummy budget data for testing different progress bar states
/// TO DELETE LATER - For development/testing only
class BudgetDummyData {
  static Future<void> seedDummyData(AppDatabase database) async {
    // Clear existing categories
    await database.categoryDao.deleteAllCategories();

    // Low usage scenario (under 50%)
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Food',
        color: 0xFFF97316, // Orange
        iconCodePoint: '${Icons.fastfood.codePoint}',
        budget: const Value(520.00),
        spent: const Value(150.00), // 30% usage
      ),
    );

    // Medium usage scenario (50%-80%)
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Transport',
        color: 0xFFEC4899, // Pink
        iconCodePoint: '${Icons.directions_car.codePoint}',
        budget: const Value(300.00),
        spent: const Value(200.00), // 66% usage
      ),
    );

    // High usage scenario (over 80%)
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Utilities',
        color: 0xFFFBBF24, // Yellow
        iconCodePoint: '${Icons.lightbulb.codePoint}',
        budget: const Value(200.00),
        spent: const Value(180.00), // 90% usage
      ),
    );

    // Additional test cases
    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Entertainment',
        color: 0xFF8B5CF6, // Purple
        iconCodePoint: '${Icons.movie.codePoint}',
        budget: const Value(400.00),
        spent: const Value(100.00), // 25% usage - GOOD
      ),
    );

    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Healthcare',
        color: 0xFF14B8A6, // Teal
        iconCodePoint: '${Icons.local_hospital.codePoint}',
        budget: const Value(600.00),
        spent: const Value(450.00), // 75% usage - WARNING
      ),
    );

    await database.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'Shopping',
        color: 0xFFEF4444, // Red
        iconCodePoint: '${Icons.shopping_bag.codePoint}',
        budget: const Value(350.00),
        spent: const Value(340.00), // 97% usage - IN RISK
      ),
    );
  }
}
