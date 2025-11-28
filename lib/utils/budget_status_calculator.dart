import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Utility class for calculating budget status indicators (percentage, color, icon, text)
/// Used by both budget_setting_screen and home_screen for consistent status display
class BudgetStatusCalculator {
  /// Calculate the percentage of budget used
  static double calculatePercentage(double spent, double budget) {
    if (budget <= 0) return 0.0;
    return spent / budget;
  }

  /// Get status text based on percentage used
  /// - < 50%: "Good"
  /// - 50-80%: "Warning"
  /// - >= 80%: "In Risk"
  static String getStatusText(double percentage) {
    if (percentage < 0.5) return AppStrings.statusGood;
    if (percentage < 0.8) return AppStrings.statusWarning;
    return AppStrings.statusInRisk;
  }

  /// Get status color based on percentage used
  /// - < 50%: Green
  /// - 50-80%: Orange
  /// - >= 80%: Red
  static Color getStatusColor(double percentage) {
    if (percentage < 0.5) return AppColors.green;
    if (percentage < 0.8) return AppColors.orange;
    return AppColors.red;
  }

  /// Get status icon based on percentage used
  /// - < 50%: check_circle (success)
  /// - 50-80%: warning
  /// - >= 80%: error
  static IconData getStatusIcon(double percentage) {
    if (percentage < 0.5) return Icons.check_circle;
    if (percentage < 0.8) return Icons.warning;
    return Icons.error;
  }

  /// Get filter icon for status dropdown
  static IconData getFilterIcon(String status) {
    switch (status) {
      case 'Good':
        return Icons.check_circle;
      case 'Warning':
        return Icons.warning;
      case 'In Risk':
        return Icons.error;
      default:
        return Icons.filter_list;
    }
  }

  /// Get filter color for status dropdown
  static Color getFilterColor(String status) {
    switch (status) {
      case 'Good':
        return AppColors.green;
      case 'Warning':
        return AppColors.orange;
      case 'In Risk':
        return AppColors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}
