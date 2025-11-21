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
  Future<Category?> getCategoryById(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingleOrNull();

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  // Update category budget
  Future<int> updateCategoryBudget(int id, double budget) =>
      (update(categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(budget: Value(budget)));

  // Update category spent
  Future<int> updateCategorySpent(int id, double spent) =>
      (update(categories)..where((c) => c.id.equals(id)))
          .write(CategoriesCompanion(spent: Value(spent)));

  // Update category
  Future<bool> updateCategory(Category category) =>
      update(categories).replace(category);

  // Delete category
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  // Delete all categories
  Future<int> deleteAllCategories() => delete(categories).go();
}
