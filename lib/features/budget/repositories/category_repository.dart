import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/category_dao.dart';

import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';

/// Repository for managing category operations
/// Abstracts database access from UI layer
class CategoryRepository implements ICategoryRepository {
  final CategoryDao _categoryDao;

  CategoryRepository(AppDatabase database)
      : _categoryDao = database.categoryDao;

  /// Watch all categories with reactive updates
  Stream<List<Category>> watchAllCategories() {
    return _categoryDao.watchAllCategories();
  }

  /// Get all categories as a one-time snapshot
  Future<List<Category>> getAllCategories() {
    return _categoryDao.getAllCategories();
  }

  /// Get a single category by ID
  Future<Category?> getCategoryById(int id) {
    return _categoryDao.getCategoryById(id);
  }

  /// Insert a new category
  Future<int> insertCategory(CategoriesCompanion category) async {
    try {
      return await _categoryDao.insertCategory(category);
    } catch (e) {
      throw Exception('Failed to insert category: $e');
    }
  }

  /// Update an existing category
  Future<void> updateCategory(Category category) async {
    try {
      await _categoryDao.updateCategory(category);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category by ID
  Future<void> deleteCategory(int id) async {
    try {
      await _categoryDao.deleteCategory(id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Update category budget
  Future<void> updateCategoryBudget(int categoryId, double budget) async {
    try {
      await _categoryDao.updateCategoryBudget(categoryId, budget);
    } catch (e) {
      throw Exception('Failed to update category budget: $e');
    }
  }

  /// Update category spent amount
  Future<void> updateCategorySpent(int categoryId, double spent) async {
    try {
      await _categoryDao.updateCategorySpent(categoryId, spent);
    } catch (e) {
      throw Exception('Failed to update category spent: $e');
    }
  }

  /// Get categories sorted by name
  Future<List<Category>> getCategoriesSortedByName() async {
    final categories = await getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  /// Get categories sorted by budget (highest first)
  Future<List<Category>> getCategoriesSortedByBudget() async {
    final categories = await getAllCategories();
    categories.sort((a, b) => b.budget.compareTo(a.budget));
    return categories;
  }

  /// Get categories with budget > 0
  Future<List<Category>> getActiveCategoriesWithBudget() async {
    final categories = await getAllCategories();
    return categories.where((c) => c.budget > 0).toList();
  }
}
