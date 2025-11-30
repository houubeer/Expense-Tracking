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
  @override
  Stream<List<Category>> watchAllCategories() {
    return _categoryDao.watchAllCategories();
  }

  /// Get all categories as a one-time snapshot
  @override
  Future<List<Category>> getAllCategories() {
    return _categoryDao.getAllCategories();
  }

  /// Get a single category by ID
  @override
  Future<Category?> getCategoryById(int id) {
    return _categoryDao.getCategoryById(id);
  }

  /// Insert a new category
  @override
  Future<int> insertCategory(CategoriesCompanion category) async {
    try {
      return await _categoryDao.insertCategory(category);
    } catch (e) {
      throw Exception('Failed to insert category: $e');
    }
  }

  /// Update an existing category
  @override
  Future<void> updateCategory(Category category) async {
    try {
      await _categoryDao.updateCategory(category);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Delete a category by ID
  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _categoryDao.deleteCategory(id);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  /// Update category budget
  @override
  Future<void> updateCategoryBudget(
      int categoryId, double budget, int currentVersion) async {
    try {
      await _categoryDao.updateCategoryBudget(
          categoryId, budget, currentVersion);
    } catch (e) {
      throw Exception('Failed to update category budget: $e');
    }
  }

  /// Update category spent amount
  @override
  Future<void> updateCategorySpent(
      int categoryId, double spent, int currentVersion) async {
    try {
      await _categoryDao.updateCategorySpent(categoryId, spent, currentVersion);
    } catch (e) {
      throw Exception('Failed to update category spent: $e');
    }
  }

  /// Get categories sorted by name
  @override
  Future<List<Category>> getCategoriesSortedByName() async {
    final categories = await getAllCategories();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  /// Get categories sorted by budget (highest first)
  @override
  Future<List<Category>> getCategoriesSortedByBudget() async {
    final categories = await getAllCategories();
    categories.sort((a, b) => b.budget.compareTo(a.budget));
    return categories;
  }

  /// Get categories with budget > 0
  @override
  Future<List<Category>> getActiveCategoriesWithBudget() async {
    final categories = await getAllCategories();
    return categories.where((c) => c.budget > 0).toList();
  }
}
