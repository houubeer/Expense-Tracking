import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Read-only category operations (ISP - Interface Segregation Principle)
/// Clients that only need to read categories don't depend on mutation methods
abstract class ICategoryReader {
  Stream<List<Category>> watchAllCategories();
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(int id);
}
