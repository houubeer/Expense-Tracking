import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';
import '../models/expense_model.dart';

/// Service for budget-related calculations and analysis
class BudgetCalculationService {
  /// Calculate usage percentage (0.0 to 1.0+)
  double calculateUsagePercentage(double used, double total) {
    if (total <= 0) return 0.0;
    return used / total;
  }

  /// Get remaining budget
  double getRemainingBudget(double total, double used) {
    return total - used;
  }

  /// Get budget status based on percentage
  /// Reuses existing BudgetStatusCalculator utility
  String getBudgetStatus(double percentage) {
    return BudgetStatusCalculator.getStatusText(percentage);
  }

  /// Get category distribution from expenses
  /// Returns a map of category name to total amount
  Map<String, double> getCategoryDistribution(List<ManagerExpense> expenses) {
    final distribution = <String, double>{};

    for (final expense in expenses) {
      distribution[expense.category] =
          (distribution[expense.category] ?? 0.0) + expense.amount;
    }

    return distribution;
  }

  /// Get monthly distribution from expenses
  /// Returns a map of month name to total amount
  Map<String, double> getMonthlyDistribution(List<ManagerExpense> expenses) {
    final distribution = <String, double>{};

    for (final expense in expenses) {
      final monthKey = _getMonthKey(expense.date);
      distribution[monthKey] = (distribution[monthKey] ?? 0.0) + expense.amount;
    }

    return distribution;
  }

  /// Get total amount from expenses
  double getTotalAmount(List<ManagerExpense> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get average expense amount
  double getAverageAmount(List<ManagerExpense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return getTotalAmount(expenses) / expenses.length;
  }

  /// Get expenses count by status
  Map<ExpenseStatus, int> getExpenseCountByStatus(
      List<ManagerExpense> expenses) {
    final counts = <ExpenseStatus, int>{};

    for (final status in ExpenseStatus.values) {
      counts[status] =
          expenses.where((exp) => exp.status == status).length;
    }

    return counts;
  }

  /// Get total amount by status
  Map<ExpenseStatus, double> getTotalAmountByStatus(
      List<ManagerExpense> expenses) {
    final totals = <ExpenseStatus, double>{};

    for (final status in ExpenseStatus.values) {
      totals[status] = expenses
          .where((exp) => exp.status == status)
          .fold(0.0, (sum, exp) => sum + exp.amount);
    }

    return totals;
  }

  /// Calculate budget health score (0-100)
  /// 100 = excellent, 0 = critical
  int calculateBudgetHealthScore(double usagePercentage) {
    if (usagePercentage <= 0.5) return 100; // Excellent
    if (usagePercentage <= 0.7) return 80; // Good
    if (usagePercentage <= 0.85) return 60; // Fair
    if (usagePercentage <= 0.95) return 40; // Warning
    if (usagePercentage < 1.0) return 20; // Critical
    return 0; // Exceeded
  }

  /// Get top spending categories
  /// Returns list of category names sorted by total amount (descending)
  List<MapEntry<String, double>> getTopSpendingCategories(
    List<ManagerExpense> expenses, {
    int limit = 5,
  }) {
    final distribution = getCategoryDistribution(expenses);
    final sorted = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  /// Get spending trend (increasing/decreasing/stable)
  /// Compares current month with previous month
  String getSpendingTrend(
    List<ManagerExpense> currentMonthExpenses,
    List<ManagerExpense> previousMonthExpenses,
  ) {
    final currentTotal = getTotalAmount(currentMonthExpenses);
    final previousTotal = getTotalAmount(previousMonthExpenses);

    if (previousTotal == 0) return 'N/A';

    final changePercentage = ((currentTotal - previousTotal) / previousTotal);

    if (changePercentage > 0.1) return 'Increasing';
    if (changePercentage < -0.1) return 'Decreasing';
    return 'Stable';
  }

  /// Helper method to get month key from date
  String _getMonthKey(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
