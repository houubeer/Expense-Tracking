import 'package:expense_tracking_desktop_app/utils/status/i_budget_status_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/status/good_status_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/status/warning_status_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/status/in_risk_status_strategy.dart';

/// Factory for creating budget status strategies (Open/Closed Principle)
/// To add new status types, create new strategy class and add to _strategies list
class BudgetStatusFactory {
  static final List<IBudgetStatusStrategy> _strategies = [
    InRiskStatusStrategy(), // Check highest severity first
    WarningStatusStrategy(),
    GoodStatusStrategy(),
  ];

  /// Get appropriate status strategy based on percentage
  static IBudgetStatusStrategy getStrategy(double percentage) {
    return _strategies.firstWhere(
      (strategy) => strategy.matches(percentage),
      orElse: () => GoodStatusStrategy(), // Default fallback
    );
  }

  /// Get strategy by status text (for filters)
  static IBudgetStatusStrategy? getStrategyByText(String statusText) {
    try {
      return _strategies.firstWhere(
        (strategy) => strategy.statusText == statusText,
      );
    } catch (_) {
      return null;
    }
  }
}
