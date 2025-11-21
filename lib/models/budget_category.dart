import 'package:flutter/material.dart';

/// Budget category model for UI representation
class BudgetCategory {
  final String name;
  final double spent;
  final double total;
  final Color color;

  BudgetCategory({
    required this.name,
    required this.spent,
    required this.total,
    required this.color,
  });

  /// Calculate percentage spent
  double get percentage => total > 0 ? (spent / total) : 0.0;

  /// Get remaining budget
  double get remaining => total - spent;

  /// Check if budget is exceeded
  bool get isOverBudget => spent > total;

  /// Get status based on percentage
  BudgetStatus get status {
    if (percentage < 0.5) return BudgetStatus.good;
    if (percentage < 0.8) return BudgetStatus.warning;
    return BudgetStatus.inRisk;
  }
}

/// Budget status enum
enum BudgetStatus {
  good,
  warning,
  inRisk,
}
