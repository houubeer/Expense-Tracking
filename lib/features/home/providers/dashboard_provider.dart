import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';

/// Dashboard state model - holds all computed dashboard data
class DashboardState {
  final int activeCategories;
  final double totalBudget;
  final double totalExpenses;
  final double totalBalance;
  final double dailyAverage;
  final List<ExpenseWithCategory> recentExpenses;
  final List<CategoryBudgetView> budgetData;

  const DashboardState({
    required this.activeCategories,
    required this.totalBudget,
    required this.totalExpenses,
    required this.totalBalance,
    required this.dailyAverage,
    required this.recentExpenses,
    required this.budgetData,
  });

  // Computed properties (logic in state, not UI)
  String get balanceTrend {
    if (totalBudget == 0) return '+0.0%';
    final percentage = (totalBalance / totalBudget) * 100;
    return totalBalance >= 0
        ? '+${percentage.toStringAsFixed(1)}%'
        : '${percentage.toStringAsFixed(1)}%';
  }

  Color get balanceColor => totalBalance >= 0 ? AppColors.accent : AppColors.red;

  String get expenseTrend {
    if (totalBudget == 0) return '-0.0%';
    return '-${((totalExpenses / totalBudget) * 100).toStringAsFixed(1)}%';
  }

  String get dailyAverageTrend {
    if (totalBudget == 0) return '-0.0%';
    final dailyBudget = totalBudget / 30;
    return '-${((dailyAverage / dailyBudget) * 100).toStringAsFixed(1)}%';
  }

  String get categoriesTrend => activeCategories > 0 ? '+$activeCategories' : '0';

  factory DashboardState.loading() {
    return const DashboardState(
      activeCategories: 0,
      totalBudget: 0,
      totalExpenses: 0,
      totalBalance: 0,
      dailyAverage: 0,
      recentExpenses: [],
      budgetData: [],
    );
  }

  /// Create dashboard state from stream data (all calculations here)
  factory DashboardState.fromData({
    required List<CategoryBudgetView> budgets,
    required double totalBudget,
    required double totalExpenses,
    required List<ExpenseWithCategory> expenses,
  }) {
    return DashboardState(
      activeCategories: budgets.length,
      totalBudget: totalBudget,
      totalExpenses: totalExpenses,
      totalBalance: totalBudget - totalExpenses,
      dailyAverage: totalExpenses / 30,
      recentExpenses: expenses.take(10).toList(),
      budgetData: budgets,
    );
  }
}
