import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';

abstract class IBudgetRepository {
  Stream<List<CategoryBudgetView>> watchCategoryBudgets();
  Stream<List<CategoryBudgetView>> watchCategoryBudgetsByStatus(BudgetStatus status);
  Stream<List<CategoryBudgetView>> watchActiveCategoryBudgets();
  Stream<List<CategoryBudgetView>> watchCategoryBudgetsSortedBySpending();
  Stream<List<CategoryBudgetView>> watchTopSpendingCategories(int limit);
  Stream<double> watchTotalBudget();
  Stream<double> watchTotalSpent();
  Stream<double> watchTotalRemaining();
  Stream<double> watchOverallBudgetHealth();
  Stream<Map<BudgetStatus, int>> watchCategoryCountByStatus();
  Future<List<CategoryBudgetView>> getCategoryBudgets();
}
