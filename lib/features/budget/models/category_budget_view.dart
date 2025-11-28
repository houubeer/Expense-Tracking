import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// View model that combines category information with calculated spending data
/// This provides a complete picture of budget status for UI rendering
class CategoryBudgetView {
  final Category category;
  final double totalSpent;
  final double remaining;
  final double percentageUsed;
  final BudgetStatus status;

  CategoryBudgetView({
    required this.category,
    required this.totalSpent,
  })  : remaining = category.budget - totalSpent,
        percentageUsed =
            category.budget > 0 ? (totalSpent / category.budget * 100) : 0,
        status = _calculateStatus(totalSpent, category.budget);

  static BudgetStatus _calculateStatus(double spent, double budget) {
    if (budget <= 0) return BudgetStatus.noBudget;
    final percentage = (spent / budget * 100);

    if (percentage >= 100) return BudgetStatus.exceeded;
    if (percentage >= 90) return BudgetStatus.critical;
    if (percentage >= 75) return BudgetStatus.warning;
    if (percentage >= 50) return BudgetStatus.moderate;
    return BudgetStatus.good;
  }

  bool get isOverBudget => totalSpent > category.budget;
  bool get hasNoBudget => category.budget <= 0;
}

enum BudgetStatus {
  noBudget, // No budget set
  good, // < 50% used
  moderate, // 50-75% used
  warning, // 75-90% used
  critical, // 90-100% used
  exceeded, // > 100% used
}
