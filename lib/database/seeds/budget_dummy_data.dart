import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Dummy budget data for testing and displaying a neat dashboard
/// TO DELETE LATER - For development/testing only
class BudgetDummyData {
  static Future<void> seedDummyData(AppDatabase database) async {
    // Clear existing data
    await database.categoryDao.deleteAllCategories();

    // Create comprehensive category set for a business expense tracker
    final categories = [
      // High spending categories
      {
        'name': 'Marketing',
        'color': 0xFFEC4899, // Pink
        'icon': Icons.campaign,
        'budget': 15000.00,
        'spent': 12500.00, // 83%
      },
      {
        'name': 'Travel',
        'color': 0xFF9333EA, // Purple
        'icon': Icons.flight,
        'budget': 10000.00,
        'spent': 8500.00, // 85%
      },
      {
        'name': 'Software',
        'color': 0xFF06B6D4, // Teal
        'icon': Icons.computer,
        'budget': 8000.00,
        'spent': 6700.00, // 84%
      },
      {
        'name': 'Office Supplies',
        'color': 0xFF6366F1, // Indigo
        'icon': Icons.inventory_2,
        'budget': 5000.00,
        'spent': 4245.50, // 85%
      },
      {
        'name': 'Utilities',
        'color': 0xFFF59E0B, // Amber
        'icon': Icons.lightbulb,
        'budget': 3000.00,
        'spent': 2250.00, // 75%
      },
      // Medium spending categories
      {
        'name': 'Equipment',
        'color': 0xFF10B981, // Green
        'icon': Icons.devices,
        'budget': 2500.00,
        'spent': 1800.00, // 72%
      },
      {
        'name': 'Training',
        'color': 0xFFA855F7, // Light Purple
        'icon': Icons.school,
        'budget': 2000.00,
        'spent': 1200.00, // 60%
      },
      {
        'name': 'Maintenance',
        'color': 0xFFFBBF24, // Light Amber
        'icon': Icons.build,
        'budget': 1500.00,
        'spent': 950.00, // 63%
      },
      // Lower spending categories
      {
        'name': 'Subscriptions',
        'color': 0xFF22D3EE, // Light Cyan
        'icon': Icons.subscriptions,
        'budget': 800.00,
        'spent': 450.00, // 56%
      },
      {
        'name': 'Miscellaneous',
        'color': 0xFFF472B6, // Light Pink
        'icon': Icons.more_horiz,
        'budget': 500.00,
        'spent': 320.00, // 64%
      },
    ];

    // Insert categories
    final categoryIds = <String, int>{};
    for (var cat in categories) {
      final id = await database.categoryDao.insertCategory(
        CategoriesCompanion.insert(
          name: cat['name'] as String,
          color: cat['color'] as int,
          iconCodePoint: '${(cat['icon'] as IconData).codePoint}',
          budget: Value(cat['budget'] as double),
          spent: Value(cat['spent'] as double),
        ),
      );
      categoryIds[cat['name'] as String] = id;
    }

    // Add sample expenses for recent transactions
    final now = DateTime.now();
    final expenses = [
      {
        'description': 'Google Ads Campaign',
        'amount': 3500.00,
        'category': 'Marketing',
        'daysAgo': 1,
      },
      {
        'description': 'Flight tickets to conference',
        'amount': 1850.00,
        'category': 'Travel',
        'daysAgo': 2,
      },
      {
        'description': 'Adobe Creative Cloud',
        'amount': 650.00,
        'category': 'Software',
        'daysAgo': 3,
      },
      {
        'description': 'Printer paper and ink',
        'amount': 245.50,
        'category': 'Office Supplies',
        'daysAgo': 4,
      },
      {
        'description': 'Electricity bill',
        'amount': 850.00,
        'category': 'Utilities',
        'daysAgo': 5,
      },
      {
        'description': 'New laptops (2x)',
        'amount': 1200.00,
        'category': 'Equipment',
        'daysAgo': 6,
      },
      {
        'description': 'Online course subscriptions',
        'amount': 400.00,
        'category': 'Training',
        'daysAgo': 7,
      },
      {
        'description': 'Office AC repair',
        'amount': 450.00,
        'category': 'Maintenance',
        'daysAgo': 8,
      },
      {
        'description': 'Slack workspace',
        'amount': 120.00,
        'category': 'Subscriptions',
        'daysAgo': 9,
      },
      {
        'description': 'Team lunch',
        'amount': 180.00,
        'category': 'Miscellaneous',
        'daysAgo': 10,
      },
      {
        'description': 'Social media ads',
        'amount': 2200.00,
        'category': 'Marketing',
        'daysAgo': 12,
      },
      {
        'description': 'Hotel accommodation',
        'amount': 950.00,
        'category': 'Travel',
        'daysAgo': 14,
      },
      {
        'description': 'Microsoft 365',
        'amount': 380.00,
        'category': 'Software',
        'daysAgo': 15,
      },
      {
        'description': 'Office furniture',
        'amount': 1500.00,
        'category': 'Office Supplies',
        'daysAgo': 18,
      },
      {
        'description': 'Internet bill',
        'amount': 450.00,
        'category': 'Utilities',
        'daysAgo': 20,
      },
    ];

    // Insert expenses
    for (var expense in expenses) {
      final categoryId = categoryIds[expense['category'] as String];
      if (categoryId != null) {
        await database.expenseDao.insertExpense(
          ExpensesCompanion.insert(
            description: expense['description'] as String,
            amount: expense['amount'] as double,
            date: now.subtract(Duration(days: expense['daysAgo'] as int)),
            categoryId: categoryId,
          ),
        );
      }
    }
  }
}
