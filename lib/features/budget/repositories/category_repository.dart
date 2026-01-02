import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/category_dao.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/core/validators/category_validators.dart';
import 'package:expense_tracking_desktop_app/core/exceptions.dart';

/// Repository for managing category operations
/// Abstracts database access from UI layer and validates business rules
class CategoryRepository implements ICategoryRepository {

  CategoryRepository(AppDatabase database)
      : _categoryDao = database.categoryDao;
  final CategoryDao _categoryDao;

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

  /// Insert a new category with validation
  @override
  Future<int> insertCategory(CategoriesCompanion category) async {
    // Validate category data before database insertion
    _validateCategoryData(category);

    try {
      return await _categoryDao.insertCategory(category);
    } catch (e) {
      throw Exception('Failed to insert category: $e');
    }
  }

  /// Update an existing category with validation
  @override
  Future<void> updateCategory(Category category) async {
    // Validate category data
    _validateCategoryForUpdate(category);

    try {
      await _categoryDao.updateCategory(category);
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  /// Validates category data for insertion
  void _validateCategoryData(CategoriesCompanion category) {
    // Validate name
    if (category.name.present) {
      final nameError =
          CategoryValidators.validateCategoryName(category.name.value);
      if (nameError != null) {
        throw ValidationException(nameError);
      }
    }

    // Validate budget
    if (category.budget.present) {
      final budgetError =
          CategoryValidators.validateBudget(category.budget.value.toString());
      if (budgetError != null) {
        throw ValidationException(budgetError);
      }
    }

    // Validate color
    if (category.color.present) {
      final colorError = CategoryValidators.validateColor(category.color.value);
      if (colorError != null) {
        throw ValidationException(colorError);
      }
    }

    // Validate icon
    if (category.iconCodePoint.present) {
      final iconError = CategoryValidators.validateIconCodePoint(
          category.iconCodePoint.value,);
      if (iconError != null) {
        throw ValidationException(iconError);
      }
    }
  }

  /// Validates category for update operations
  void _validateCategoryForUpdate(Category category) {
    final nameError = CategoryValidators.validateCategoryName(category.name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final budgetError =
        CategoryValidators.validateBudget(category.budget.toString());
    if (budgetError != null) {
      throw ValidationException(budgetError);
    }

    final colorError = CategoryValidators.validateColor(category.color);
    if (colorError != null) {
      throw ValidationException(colorError);
    }

    final iconError =
        CategoryValidators.validateIconCodePoint(category.iconCodePoint);
    if (iconError != null) {
      throw ValidationException(iconError);
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
      int categoryId, double budget, int currentVersion,) async {
    try {
      await _categoryDao.updateCategoryBudget(
          categoryId, budget, currentVersion,);
    } catch (e) {
      throw Exception('Failed to update category budget: $e');
    }
  }

  /// Update category spent amount
  @override
  Future<void> updateCategorySpent(
      int categoryId, double spent, int currentVersion,) async {
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
