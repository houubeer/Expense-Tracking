import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';

/// Budget analytics operations (ISP - Interface Segregation Principle)
/// For widgets that need aggregated budget metrics and health indicators
abstract class IBudgetAnalytics {
  Stream<double> watchTotalRemaining();
  Stream<double> watchOverallBudgetHealth();
  Stream<Map<BudgetStatus, int>> watchCategoryCountByStatus();
}
