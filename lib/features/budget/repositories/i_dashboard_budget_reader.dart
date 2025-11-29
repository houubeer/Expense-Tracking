import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';

/// Dashboard-specific budget queries (ISP - Interface Segregation Principle)
/// Only dashboard view model needs these specific metrics
abstract class IDashboardBudgetReader {
  Stream<List<CategoryBudgetView>> watchActiveCategoryBudgets();
  Stream<double> watchTotalBudget();
  Stream<double> watchTotalSpent();
}
