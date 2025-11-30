import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  final ConnectivityService? _connectivityService;

  CategoryDao(super.db, [this._connectivityService]);

  // Watch all categories
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final result = await select(categories).get();
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      final result = await (select(categories)..where((c) => c.id.equals(id)))
          .getSingleOrNull();
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to get category by id - $e');
    }
  }

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) async {
    try {
      // Validate budget
      if (category.budget.present) {
        final budget = category.budget.value;
        if (budget < 0) {
          throw Exception('Budget cannot be negative, got: $budget');
        }
        if (budget > 1000000000) {
          throw Exception('Budget is too large: $budget');
        }
      }

      // Validate spent
      if (category.spent.present) {
        final spent = category.spent.value;
        if (spent < 0) {
          throw Exception('Spent amount cannot be negative, got: $spent');
        }
      }

      final id = await into(categories).insert(category);
      _connectivityService?.markSuccessfulOperation();
      return id;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to insert category - $e');
    }
  }

  // Update category budget
  Future<int> updateCategoryBudget(int id, double budget) async {
    try {
      if (budget < 0) {
        throw Exception('Budget cannot be negative, got: $budget');
      }
      if (budget > 1000000000) {
        throw Exception('Budget is too large: $budget');
      }

      // Get current category to check version
      final category = await getCategoryById(id);
      if (category == null) {
        throw Exception('Category not found with id: $id');
      }

      // Update with version increment for optimistic locking
      final rowsAffected = await (update(categories)
            ..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(
              budget: Value(budget), version: Value(category.version + 1)));

      if (rowsAffected == 0) {
        throw Exception(
            'Failed to update category budget - concurrent modification detected');
      }

      _connectivityService?.markSuccessfulOperation();
      return rowsAffected;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to update category budget - $e');
    }
  }

  // Update category spent
  Future<int> updateCategorySpent(int id, double spent) async {
    try {
      if (spent < 0) {
        throw Exception('Spent amount cannot be negative, got: $spent');
      }

      // Get current category to check version
      final category = await getCategoryById(id);
      if (category == null) {
        throw Exception('Category not found with id: $id');
      }

      // Update with version increment for optimistic locking
      final rowsAffected = await (update(categories)
            ..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(
              spent: Value(spent), version: Value(category.version + 1)));

      if (rowsAffected == 0) {
        throw Exception(
            'Failed to update category spent - concurrent modification detected');
      }

      _connectivityService?.markSuccessfulOperation();
      return rowsAffected;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to update category spent - $e');
    }
  }

  // Update category
  Future<bool> updateCategory(Category category) async {
    try {
      // Validate budget
      if (category.budget < 0) {
        throw Exception('Budget cannot be negative, got: ${category.budget}');
      }
      if (category.budget > 1000000000) {
        throw Exception('Budget is too large: ${category.budget}');
      }

      // Validate spent
      if (category.spent < 0) {
        throw Exception(
            'Spent amount cannot be negative, got: ${category.spent}');
      }

      // Update with version increment for optimistic locking
      final updatedCategory = category.copyWith(version: category.version + 1);
      final result = await update(categories).replace(updatedCategory);

      if (!result) {
        throw Exception(
            'Failed to update category - concurrent modification detected');
      }

      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to update category - $e');
    }
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    try {
      final result = await (delete(categories)..where((c) => c.id.equals(id))).go();
      _connectivityService?.markSuccessfulOperation();
      return result;
    } catch (e) {
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to delete category - $e');
    }
  }

  // Delete all categories
  Future<int> deleteAllCategories() => delete(categories).go();
}
