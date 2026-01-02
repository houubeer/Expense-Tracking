/// Repository for aggregating platform-wide expense data
/// This provides analytics across all companies
class PlatformExpenseRepository {

  PlatformExpenseRepository() {
    _initializeMockData();
  }
  final List<Expense> _expenses = [];

  /// Initialize with mock expense data across companies
  void _initializeMockData() {
    final now = DateTime.now();
    _expenses.addAll([
      // Tech Innovators Inc. expenses
      Expense(
        id: 'e1',
        companyId: 'c1',
        amount: 1250.00,
        category: 'Software',
        date: now.subtract(const Duration(days: 5)),
        description: 'Cloud hosting services',
      ),
      Expense(
        id: 'e2',
        companyId: 'c1',
        amount: 850.00,
        category: 'Office Supplies',
        date: now.subtract(const Duration(days: 10)),
        description: 'Office equipment',
      ),
      Expense(
        id: 'e3',
        companyId: 'c1',
        amount: 3200.00,
        category: 'Travel',
        date: now.subtract(const Duration(days: 15)),
        description: 'Business trip to conference',
      ),
      // Global Solutions Ltd. expenses
      Expense(
        id: 'e4',
        companyId: 'c2',
        amount: 2100.00,
        category: 'Marketing',
        date: now.subtract(const Duration(days: 3)),
        description: 'Digital advertising campaign',
      ),
      Expense(
        id: 'e5',
        companyId: 'c2',
        amount: 950.00,
        category: 'Software',
        date: now.subtract(const Duration(days: 7)),
        description: 'Software licenses',
      ),
      // StartUp Ventures expenses
      Expense(
        id: 'e6',
        companyId: 'c3',
        amount: 450.00,
        category: 'Office Supplies',
        date: now.subtract(const Duration(days: 2)),
        description: 'Stationery and supplies',
      ),
      Expense(
        id: 'e7',
        companyId: 'c3',
        amount: 1800.00,
        category: 'Equipment',
        date: now.subtract(const Duration(days: 12)),
        description: 'New laptops',
      ),
      // Enterprise Corp expenses
      Expense(
        id: 'e8',
        companyId: 'c4',
        amount: 5600.00,
        category: 'Travel',
        date: now.subtract(const Duration(days: 4)),
        description: 'International business trip',
      ),
      Expense(
        id: 'e9',
        companyId: 'c4',
        amount: 3400.00,
        category: 'Software',
        date: now.subtract(const Duration(days: 8)),
        description: 'Enterprise software suite',
      ),
      Expense(
        id: 'e10',
        companyId: 'c4',
        amount: 2200.00,
        category: 'Marketing',
        date: now.subtract(const Duration(days: 6)),
        description: 'Marketing materials',
      ),
    ]);
  }

  /// Get total expenses across all companies
  double getTotalExpenses() {
    return _expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Get expenses within a date range
  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((e) => e.date.isAfter(start) && e.date.isBefore(end))
        .toList();
  }

  /// Get expense breakdown by category
  Map<String, double> getExpensesByCategory() {
    final categoryTotals = <String, double>{};
    for (final expense in _expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }
    return categoryTotals;
  }

  /// Get monthly growth percentage
  double getMonthlyGrowth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    final currentMonthExpenses = _expenses
        .where((e) => e.date.isAfter(currentMonth))
        .fold(0.0, (sum, e) => sum + e.amount);

    final lastMonthExpenses = _expenses
        .where(
            (e) => e.date.isAfter(lastMonth) && e.date.isBefore(currentMonth),)
        .fold(0.0, (sum, e) => sum + e.amount);

    if (lastMonthExpenses == 0) return 0.0;
    return ((currentMonthExpenses - lastMonthExpenses) / lastMonthExpenses) *
        100;
  }

  /// Get monthly expense trend (last 6 months)
  Map<String, double> getMonthlyTrend() {
    final now = DateTime.now();
    final trend = <String, double>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final nextMonth = DateTime(now.year, now.month - i + 1);
      final monthName = _getMonthName(month.month);

      final monthExpenses = _expenses
          .where((e) => e.date.isAfter(month) && e.date.isBefore(nextMonth))
          .fold(0.0, (sum, e) => sum + e.amount);

      trend[monthName] = monthExpenses;
    }

    return trend;
  }

  /// Get top spending companies
  Map<String, double> getTopSpendingCompanies() {
    final companyTotals = <String, double>{};
    for (final expense in _expenses) {
      companyTotals[expense.companyId] =
          (companyTotals[expense.companyId] ?? 0.0) + expense.amount;
    }
    return companyTotals;
  }

  /// Helper to get month name
  String _getMonthName(int month) {
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
      'Dec',
    ];
    return months[month - 1];
  }
}

/// Simple expense model for platform analytics
class Expense {

  const Expense({
    required this.id,
    required this.companyId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });
  final String id;
  final String companyId;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
}
