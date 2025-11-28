import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';

/// Dashboard statistics model
class DashboardStats {
  final int activeCategories;
  final double totalBudget;
  final double totalExpenses;
  final double totalBalance;
  final double dailyAverage;

  DashboardStats({
    required this.activeCategories,
    required this.totalBudget,
    required this.totalExpenses,
    required this.totalBalance,
    required this.dailyAverage,
  });

  /// Calculate balance percentage trend
  String get balanceTrend {
    if (totalBudget <= 0) return "0.0%";
    final percentage = (totalBalance / totalBudget) * 100;
    return totalBalance >= 0
        ? "+${percentage.toStringAsFixed(1)}%"
        : "-${percentage.abs().toStringAsFixed(1)}%";
  }

  /// Get balance color based on value
  Color get balanceColor =>
      totalBalance >= 0 ? AppColors.accent : AppColors.red;

  /// Calculate expense percentage trend
  String get expenseTrend {
    if (totalBudget <= 0) return "0.0%";
    return "-${((totalExpenses / totalBudget) * 100).toStringAsFixed(1)}%";
  }

  /// Calculate daily average percentage trend
  String get dailyAverageTrend {
    if (totalBudget <= 0) return "0.0%";
    final dailyBudget = totalBudget / 30;
    return "-${((dailyAverage / dailyBudget) * 100).toStringAsFixed(1)}%";
  }

  /// Calculate categories trend
  String get categoriesTrend {
    return activeCategories > 0 ? "+$activeCategories" : "0";
  }
}

/// ViewModel for dashboard/home screen calculations
class DashboardViewModel {
  /// Calculate dashboard statistics from raw data
  DashboardStats calculateStats({
    required int activeCategories,
    required double totalBudget,
    required double totalExpenses,
  }) {
    final totalBalance = totalBudget - totalExpenses;
    final dailyAverage = totalExpenses / 30;

    return DashboardStats(
      activeCategories: activeCategories,
      totalBudget: totalBudget,
      totalExpenses: totalExpenses,
      totalBalance: totalBalance,
      dailyAverage: dailyAverage,
    );
  }

  /// Calculate card width based on screen constraints
  double calculateCardWidth(double screenWidth, bool isDesktop) {
    return isDesktop ? (screenWidth - 60) / 4 : (screenWidth - 28) / 2;
  }
}
