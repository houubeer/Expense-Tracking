import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/utils/status/budget_status_factory.dart';

/// Utility class for calculating budget status indicators using Strategy Pattern
/// SATISFIES Open/Closed Principle: New status types can be added by creating new strategies
/// without modifying this calculator
class BudgetStatusCalculator {
  /// Calculate the percentage of budget used
  static double calculatePercentage(double spent, double budget) {
    if (budget <= 0) return 0.0;
    return spent / budget;
  }

  /// Get status text based on percentage used
  static String getStatusText(double percentage) {
    final strategy = BudgetStatusFactory.getStrategy(percentage);
    return strategy.statusText;
  }

  /// Get status color based on percentage used
  static Color getStatusColor(double percentage) {
    final strategy = BudgetStatusFactory.getStrategy(percentage);
    return strategy.statusColor;
  }

  /// Get status icon based on percentage used
  static IconData getStatusIcon(double percentage) {
    final strategy = BudgetStatusFactory.getStrategy(percentage);
    return strategy.statusIcon;
  }

  /// Get filter icon for status dropdown
  static IconData getFilterIcon(String status) {
    final strategy = BudgetStatusFactory.getStrategyByText(status);
    return strategy?.statusIcon ?? Icons.filter_list;
  }

  /// Get filter color for status dropdown
  static Color getFilterColor(String status) {
    final strategy = BudgetStatusFactory.getStrategyByText(status);
    return strategy?.statusColor ?? AppColors.textSecondary;
  }
}
