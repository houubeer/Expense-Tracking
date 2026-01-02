import 'package:expense_tracking_desktop_app/features/dashboard/repositories/platform_expense_repository.dart';

/// Service for calculating platform-wide expense analytics
/// Provides aggregated metrics and insights across all companies
class ExpenseAnalyticsService {

  ExpenseAnalyticsService(this._expenseRepository);
  final PlatformExpenseRepository _expenseRepository;

  /// Calculate total expenses across the platform
  double calculateTotalExpenses() {
    return _expenseRepository.getTotalExpenses();
  }

  /// Get expense breakdown by category
  /// Returns a map of category name to total amount
  Map<String, double> getCategoryBreakdown() {
    return _expenseRepository.getExpensesByCategory();
  }

  /// Get category breakdown as percentages
  Map<String, double> getCategoryPercentages() {
    final breakdown = getCategoryBreakdown();
    final total = breakdown.values.fold(0.0, (sum, amount) => sum + amount);
    
    if (total == 0) return {};
    
    return breakdown.map((category, amount) => 
      MapEntry(category, (amount / total) * 100),
    );
  }

  /// Get monthly expense trend
  /// Returns a map of month name to total expenses
  Map<String, double> getMonthlyTrend() {
    return _expenseRepository.getMonthlyTrend();
  }

  /// Get top spending companies
  /// Returns a map of company ID to total expenses
  Map<String, double> getTopSpendingCompanies() {
    return _expenseRepository.getTopSpendingCompanies();
  }

  /// Calculate month-over-month growth percentage
  double calculateMonthlyGrowth() {
    return _expenseRepository.getMonthlyGrowth();
  }

  /// Get formatted growth string with sign
  String getFormattedGrowth() {
    final growth = calculateMonthlyGrowth();
    final sign = growth >= 0 ? '+' : '';
    return '$sign${growth.toStringAsFixed(1)}%';
  }

  /// Get top spending category
  String getTopSpendingCategory() {
    final breakdown = getCategoryBreakdown();
    if (breakdown.isEmpty) return 'N/A';
    
    var topCategory = '';
    var maxAmount = 0.0;
    
    breakdown.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        topCategory = category;
      }
    });
    
    return topCategory;
  }

  /// Get average expense per company
  double getAverageExpensePerCompany(int companyCount) {
    if (companyCount == 0) return 0.0;
    return calculateTotalExpenses() / companyCount;
  }

  /// Get expense statistics
  ExpenseStatistics getStatistics() {
    final total = calculateTotalExpenses();
    final growth = calculateMonthlyGrowth();
    final topCategory = getTopSpendingCategory();
    final categoryBreakdown = getCategoryBreakdown();
    
    return ExpenseStatistics(
      totalExpenses: total,
      monthlyGrowth: growth,
      topCategory: topCategory,
      categoryCount: categoryBreakdown.length,
    );
  }
}

/// Data class for expense statistics
class ExpenseStatistics {

  const ExpenseStatistics({
    required this.totalExpenses,
    required this.monthlyGrowth,
    required this.topCategory,
    required this.categoryCount,
  });
  final double totalExpenses;
  final double monthlyGrowth;
  final String topCategory;
  final int categoryCount;
}
