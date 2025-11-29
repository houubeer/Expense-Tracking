import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Write category operations (ISP - Interface Segregation Principle)
/// Separates mutation operations from read operations
abstract class ICategoryWriter {
  Future<int> insertCategory(CategoriesCompanion category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
}
