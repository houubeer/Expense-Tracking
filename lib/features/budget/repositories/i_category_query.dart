import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Specialized category query operations (ISP - Interface Segregation Principle)
/// For clients that need sorted/filtered category lists
abstract class ICategoryQuery {
  Future<List<Category>> getCategoriesSortedByName();
  Future<List<Category>> getCategoriesSortedByBudget();
  Future<List<Category>> getActiveCategoriesWithBudget();
}
