import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Service layer for budget-related business logic
class BudgetService {
  final AppDatabase _database;

  BudgetService(this._database);

  /// Get all categories as a stream
  Stream<List<Category>> watchAllCategories() {
    return _database.categoryDao.watchAllCategories();
  }

  /// Calculate total budget across all categories
  Future<double> getTotalBudget() async {
    final categories = await _database.categoryDao.getAllCategories();
    return categories.fold<double>(0.0, (sum, cat) => sum + cat.budget);
  }

  /// Calculate total spent across all categories
  Future<double> getTotalSpent() async {
    final categories = await _database.categoryDao.getAllCategories();
    return categories.fold<double>(0.0, (sum, cat) => sum + cat.spent);
  }

  /// Calculate remaining budget
  Future<double> getRemainingBudget() async {
    final total = await getTotalBudget();
    final spent = await getTotalSpent();
    return total - spent;
  }

  /// Update category budget
  Future<void> updateCategoryBudget(int categoryId, double budget) async {
    await _database.categoryDao.updateCategoryBudget(categoryId, budget);
  }

  /// Add expense to category
  Future<void> addExpenseToCategory(int categoryId, double amount) async {
    final category = await _database.categoryDao.getCategoryById(categoryId);
    if (category != null) {
      final newSpent = category.spent + amount;
      await _database.categoryDao.updateCategorySpent(categoryId, newSpent);
    }
  }

  /// Remove expense from category
  Future<void> removeExpenseFromCategory(int categoryId, double amount) async {
    final category = await _database.categoryDao.getCategoryById(categoryId);
    if (category != null) {
      final newSpent = (category.spent - amount).clamp(0.0, double.infinity);
      await _database.categoryDao.updateCategorySpent(categoryId, newSpent);
    }
  }

  /// Check if category is over budget
  Future<bool> isCategoryOverBudget(int categoryId) async {
    final category = await _database.categoryDao.getCategoryById(categoryId);
    if (category == null) return false;
    return category.spent > category.budget;
  }
}
