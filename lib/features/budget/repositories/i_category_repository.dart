import 'package:expense_tracking_desktop_app/database/app_database.dart';

abstract class ICategoryRepository {
  Stream<List<Category>> watchAllCategories();
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
  Future<int> insertCategory(CategoriesCompanion category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<void> updateCategoryBudget(int categoryId, double budget);
  Future<void> updateCategorySpent(int categoryId, double spent);
  Future<List<Category>> getCategoriesSortedByName();
  Future<List<Category>> getCategoriesSortedByBudget();
  Future<List<Category>> getActiveCategoriesWithBudget();
}
