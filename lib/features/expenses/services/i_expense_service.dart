import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Interface for expense-related business operations
/// Abstracts the service layer for Dependency Inversion Principle compliance
abstract class IExpenseService {
  /// Create a new expense and update category spent atomically
  Future<int> createExpense(ExpensesCompanion expense);

  /// Update an existing expense and recalculate category spent atomically
  Future<void> updateExpense(Expense oldExpense, Expense newExpense);

  /// Delete an expense and update category spent atomically
  Future<void> deleteExpense(Expense expense);

  /// Watch expenses with their category information
  Stream<List<ExpenseWithCategory>> watchExpensesWithCategory();
}

/// Data class representing an expense with its associated category
/// Decouples higher layers from DAO-specific implementations
class ExpenseWithCategory {
  final Expense expense;
  final Category category;

  ExpenseWithCategory({
    required this.expense,
    required this.category,
  });

  // Convenience getters
  int get id => expense.id;
  double get amount => expense.amount;
  String get description => expense.description;
  DateTime get date => expense.date;
  int get categoryId => expense.categoryId;
  String get categoryName => category.name;
  int get categoryColor => category.color;
  String get categoryIconCodePoint => category.iconCodePoint;
}
