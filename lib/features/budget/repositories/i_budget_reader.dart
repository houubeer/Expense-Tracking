import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';

/// General budget read operations (ISP - Interface Segregation Principle)
/// For comprehensive budget views and analysis
abstract class IBudgetReader {
  Stream<List<CategoryBudgetView>> watchCategoryBudgets();
  Stream<List<CategoryBudgetView>> watchCategoryBudgetsByStatus(BudgetStatus status);
  Stream<List<CategoryBudgetView>> watchCategoryBudgetsSortedBySpending();
  Stream<List<CategoryBudgetView>> watchTopSpendingCategories(int limit);
  Future<List<CategoryBudgetView>> getCategoryBudgets();
}
