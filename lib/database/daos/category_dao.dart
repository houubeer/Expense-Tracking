import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  final ConnectivityService? _connectivityService;
  final _logger = LoggerService.instance;

  CategoryDao(super.db, [this._connectivityService]);

  // Watch all categories
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      _logger.debug('CategoryDao: getAllCategories called');
      final result = await select(categories).get();
      _connectivityService?.markSuccessfulOperation();
      _logger.info('CategoryDao: Retrieved ${result.length} categories');
      return result;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: getAllCategories failed',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      rethrow;
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      _logger.debug('CategoryDao: getCategoryById called with id=$id');
      final result = await (select(categories)..where((c) => c.id.equals(id)))
          .getSingleOrNull();
      _connectivityService?.markSuccessfulOperation();
      if (result != null) {
        _logger
            .debug('CategoryDao: Found category id=$id, name=${result.name}');
      } else {
        _logger.warning('CategoryDao: Category not found with id=$id');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: getCategoryById failed for id=$id',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to get category by id - $e');
    }
  }

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) async {
    try {
      _logger.debug('CategoryDao: insertCategory called',
          error: null, stackTrace: null);
      // Validate budget
      if (category.budget.present) {
        final budget = category.budget.value;
        if (budget < 0) {
          _logger.warning(
              'CategoryDao: Budget validation failed - negative value: $budget');
          throw Exception('Budget cannot be negative, got: $budget');
        }
        if (budget > 1000000000) {
          _logger.warning(
              'CategoryDao: Budget validation failed - too large: $budget');
          throw Exception('Budget is too large: $budget');
        }
      }

      // Validate spent
      if (category.spent.present) {
        final spent = category.spent.value;
        if (spent < 0) {
          _logger.warning(
              'CategoryDao: Spent validation failed - negative value: $spent');
          throw Exception('Spent amount cannot be negative, got: $spent');
        }
      }

      final id = await into(categories).insert(category);
      _connectivityService?.markSuccessfulOperation();
      _logger.info('CategoryDao: Inserted category with id=$id');
      return id;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: insertCategory failed',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to insert category - $e');
    }
  }

  // Update category budget
  Future<int> updateCategoryBudget(
      int id, double budget, int currentVersion) async {
    try {
      _logger.debug(
          'CategoryDao: updateCategoryBudget called - id=$id, budget=$budget, version=$currentVersion');
      if (budget < 0) {
        _logger.warning(
            'CategoryDao: Budget validation failed - negative: $budget');
        throw Exception('Budget cannot be negative, got: $budget');
      }
      if (budget > 1000000000) {
        _logger.warning(
            'CategoryDao: Budget validation failed - too large: $budget');
        throw Exception('Budget is too large: $budget');
      }

      // Update with version increment for optimistic locking
      // Using WHERE clause with both id AND version to detect concurrent modifications
      final rowsAffected = await (update(categories)
            ..where((c) => c.id.equals(id) & c.version.equals(currentVersion)))
          .write(CategoriesCompanion(
              budget: Value(budget), version: Value(currentVersion + 1)));

      if (rowsAffected == 0) {
        _logger.warning(
            'CategoryDao: updateCategoryBudget concurrent modification detected - id=$id, version=$currentVersion');
        throw Exception(
            'Failed to update category budget - concurrent modification detected or category not found');
      }

      _connectivityService?.markSuccessfulOperation();
      _logger.info(
          'CategoryDao: Updated category budget - id=$id, new budget=$budget, version=${currentVersion + 1}');
      return rowsAffected;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: updateCategoryBudget failed - id=$id',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to update category budget - $e');
    }
  }

  // Update category spent
  Future<int> updateCategorySpent(
      int id, double spent, int currentVersion) async {
    try {
      _logger.debug(
          'CategoryDao: updateCategorySpent called - id=$id, spent=$spent, version=$currentVersion');
      if (spent < 0) {
        _logger
            .warning('CategoryDao: Spent validation failed - negative: $spent');
        throw Exception('Spent amount cannot be negative, got: $spent');
      }

      // Update with version increment for optimistic locking
      // Using WHERE clause with both id AND version to detect concurrent modifications
      final rowsAffected = await (update(categories)
            ..where((c) => c.id.equals(id) & c.version.equals(currentVersion)))
          .write(CategoriesCompanion(
              spent: Value(spent), version: Value(currentVersion + 1)));

      if (rowsAffected == 0) {
        _logger.warning(
            'CategoryDao: updateCategorySpent concurrent modification detected - id=$id, version=$currentVersion');
        throw Exception(
            'Failed to update category spent - concurrent modification detected or category not found');
      }

      _connectivityService?.markSuccessfulOperation();
      _logger.info(
          'CategoryDao: Updated category spent - id=$id, new spent=$spent, version=${currentVersion + 1}');
      return rowsAffected;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: updateCategorySpent failed - id=$id',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to update category spent - $e');
    }
  }

  // Update category
  Future<bool> updateCategory(Category category) async {
    try {
      _logger.debug(
          'CategoryDao: updateCategory called - id=${category.id}, version=${category.version}');
      // Validate budget
      if (category.budget < 0) {
        _logger.warning(
            'CategoryDao: Budget validation failed - negative: ${category.budget}');
        throw Exception('Budget cannot be negative, got: ${category.budget}');
      }
      if (category.budget > 1000000000) {
        _logger.warning(
            'CategoryDao: Budget validation failed - too large: ${category.budget}');
        throw Exception('Budget is too large: ${category.budget}');
      }

      // Validate spent
      if (category.spent < 0) {
        _logger.warning(
            'CategoryDao: Spent validation failed - negative: ${category.spent}');
        throw Exception(
            'Spent amount cannot be negative, got: ${category.spent}');
      }

      // Update with version increment for optimistic locking
      final updatedCategory = category.copyWith(version: category.version + 1);
      final result = await update(categories).replace(updatedCategory);

      if (!result) {
        _logger.warning(
            'CategoryDao: updateCategory concurrent modification detected - id=${category.id}, version=${category.version}');
        throw Exception(
            'Failed to update category - concurrent modification detected');
      }

      _connectivityService?.markSuccessfulOperation();
      _logger.info(
          'CategoryDao: Updated category - id=${category.id}, version=${category.version + 1}');
      return result;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: updateCategory failed - id=${category.id}',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to update category - $e');
    }
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    try {
      _logger.debug('CategoryDao: deleteCategory called - id=$id');
      final result =
          await (delete(categories)..where((c) => c.id.equals(id))).go();
      _connectivityService?.markSuccessfulOperation();
      if (result > 0) {
        _logger.info('CategoryDao: Deleted category - id=$id');
      } else {
        _logger
            .warning('CategoryDao: Category not found for deletion - id=$id');
      }
      return result;
    } catch (e, stackTrace) {
      _logger.error('CategoryDao: deleteCategory failed - id=$id',
          error: e, stackTrace: stackTrace);
      _connectivityService?.handleConnectionFailure(e.toString());
      throw Exception('Database error: Failed to delete category - $e');
    }
  }

  // Delete all categories
  Future<int> deleteAllCategories() => delete(categories).go();
}
