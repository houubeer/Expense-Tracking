import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // Watch all categories
  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  // Get all categories
  Future<List<Category>> getAllCategories() => select(categories).get();

  // Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      return await (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();
    } catch (e) {
      throw Exception('Database error: Failed to get category by id - $e');
    }
  }

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) async {
    try {
      return await into(categories).insert(category);
    } catch (e) {
      throw Exception('Database error: Failed to insert category - $e');
    }
  }

  // Update category budget
  Future<int> updateCategoryBudget(int id, double budget) async {
    try {
      return await (update(categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(budget: Value(budget)));
    } catch (e) {
      throw Exception('Database error: Failed to update category budget - $e');
    }
  }

  // Update category spent
  Future<int> updateCategorySpent(int id, double spent) async {
    try {
      return await (update(categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(spent: Value(spent)));
    } catch (e) {
      throw Exception('Database error: Failed to update category spent - $e');
    }
  }

  // Update category
  Future<bool> updateCategory(Category category) async {
    try {
      return await update(categories).replace(category);
    } catch (e) {
      throw Exception('Database error: Failed to update category - $e');
    }
  }

  // Delete category
  Future<int> deleteCategory(int id) async {
    try {
      return await (delete(categories)..where((c) => c.id.equals(id))).go();
    } catch (e) {
      throw Exception('Database error: Failed to delete category - $e');
    }
  }

  // Delete all categories
  Future<int> deleteAllCategories() => delete(categories).go();
}
