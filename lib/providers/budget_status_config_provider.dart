import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/utils/status/i_budget_status_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/status/configurable_budget_status_strategy.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Configuration for budget status strategies
class BudgetStatusConfig {
  final List<IBudgetStatusStrategy> strategies;

  const BudgetStatusConfig({required this.strategies});

  /// Default configuration with standard thresholds
  factory BudgetStatusConfig.defaultConfig() {
    return BudgetStatusConfig(
      strategies: [
        ConfigurableBudgetStatusStrategy.atRisk(
          statusText: AppStrings.statusInRisk,
          statusColor: AppColors.red,
          statusIcon: Icons.error,
          minThreshold: 0.8,
        ),
        ConfigurableBudgetStatusStrategy.warning(
          statusText: AppStrings.statusWarning,
          statusColor: AppColors.orange,
          statusIcon: Icons.warning,
          minThreshold: 0.5,
          maxThreshold: 0.8,
        ),
        ConfigurableBudgetStatusStrategy.good(
          statusText: AppStrings.statusGood,
          statusColor: AppColors.green,
          statusIcon: Icons.check_circle,
          maxThreshold: 0.5,
        ),
      ],
    );
  }

  /// Conservative configuration (stricter thresholds)
  factory BudgetStatusConfig.conservative() {
    return BudgetStatusConfig(
      strategies: [
        ConfigurableBudgetStatusStrategy.atRisk(
          statusText: AppStrings.statusInRisk,
          statusColor: AppColors.red,
          statusIcon: Icons.error,
          minThreshold: 0.7, // Risk at 70% instead of 80%
        ),
        ConfigurableBudgetStatusStrategy.warning(
          statusText: AppStrings.statusWarning,
          statusColor: AppColors.orange,
          statusIcon: Icons.warning,
          minThreshold: 0.4, // Warning at 40% instead of 50%
          maxThreshold: 0.7,
        ),
        ConfigurableBudgetStatusStrategy.good(
          statusText: AppStrings.statusGood,
          statusColor: AppColors.green,
          statusIcon: Icons.check_circle,
          maxThreshold: 0.4,
        ),
      ],
    );
  }

  /// Relaxed configuration (more lenient thresholds)
  factory BudgetStatusConfig.relaxed() {
    return BudgetStatusConfig(
      strategies: [
        ConfigurableBudgetStatusStrategy.atRisk(
          statusText: AppStrings.statusInRisk,
          statusColor: AppColors.red,
          statusIcon: Icons.error,
          minThreshold: 0.9, // Risk at 90% instead of 80%
        ),
        ConfigurableBudgetStatusStrategy.warning(
          statusText: AppStrings.statusWarning,
          statusColor: AppColors.orange,
          statusIcon: Icons.warning,
          minThreshold: 0.6, // Warning at 60% instead of 50%
          maxThreshold: 0.9,
        ),
        ConfigurableBudgetStatusStrategy.good(
          statusText: AppStrings.statusGood,
          statusColor: AppColors.green,
          statusIcon: Icons.check_circle,
          maxThreshold: 0.6,
        ),
      ],
    );
  }

  /// Get strategy matching the given percentage
  IBudgetStatusStrategy getStrategy(double percentage) {
    return strategies.firstWhere(
      (strategy) => strategy.matches(percentage),
      orElse: () => strategies.last, // Default to last strategy
    );
  }

  /// Get strategy by status text
  IBudgetStatusStrategy? getStrategyByText(String statusText) {
    try {
      return strategies.firstWhere(
        (strategy) => strategy.statusText == statusText,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Provider for budget status configuration
/// Can be overridden to customize thresholds app-wide
final budgetStatusConfigProvider = Provider<BudgetStatusConfig>((ref) {
  return BudgetStatusConfig.defaultConfig();
});
