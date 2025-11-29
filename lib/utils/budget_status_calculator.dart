import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/utils/status/budget_status_factory.dart';
import 'package:expense_tracking_desktop_app/providers/budget_status_config_provider.dart';

/// Utility class for calculating budget status indicators using Strategy Pattern
/// SATISFIES Open/Closed Principle: New status types can be added by creating new strategies
/// SATISFIES Dependency Injection: Can use custom configuration
class BudgetStatusCalculator {
  final BudgetStatusConfig? _config;

  const BudgetStatusCalculator({BudgetStatusConfig? config}) : _config = config;

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
    return strategy?.statusColor ?? const Color(0xFF64748B); // Medium gray fallback
  }

  // Instance methods using custom configuration
  /// Get status text with custom config
  String getStatusTextWithConfig(double percentage) {
    final strategy = _config?.getStrategy(percentage) ??
        BudgetStatusFactory.getStrategy(percentage);
    return strategy.statusText;
  }

  /// Get status color with custom config
  Color getStatusColorWithConfig(double percentage) {
    final strategy = _config?.getStrategy(percentage) ??
        BudgetStatusFactory.getStrategy(percentage);
    return strategy.statusColor;
  }

  /// Get status icon with custom config
  IconData getStatusIconWithConfig(double percentage) {
    final strategy = _config?.getStrategy(percentage) ??
        BudgetStatusFactory.getStrategy(percentage);
    return strategy.statusIcon;
  }

  /// Get filter icon with custom config
  IconData getFilterIconWithConfig(String status) {
    final strategy = _config?.getStrategyByText(status) ??
        BudgetStatusFactory.getStrategyByText(status);
    return strategy?.statusIcon ?? Icons.filter_list;
  }

  /// Get filter color with custom config
  Color getFilterColorWithConfig(String status) {
    final strategy = _config?.getStrategyByText(status) ??
        BudgetStatusFactory.getStrategyByText(status);
    return strategy?.statusColor ?? const Color(0xFF64748B); // Medium gray fallback
  }
}
