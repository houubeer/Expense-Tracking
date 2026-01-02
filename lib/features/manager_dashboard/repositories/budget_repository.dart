import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/budget_model.dart';

/// Repository providing mock budget data for departments
class BudgetRepository {
  // Mock department budget data
  static final List<DepartmentBudget> _mockBudgets = [
    const DepartmentBudget(
      departmentName: 'Engineering',
      totalBudget: 150000.00,
      usedBudget: 87500.00,
    ),
    const DepartmentBudget(
      departmentName: 'Marketing',
      totalBudget: 80000.00,
      usedBudget: 62300.00,
    ),
    const DepartmentBudget(
      departmentName: 'Sales',
      totalBudget: 120000.00,
      usedBudget: 95400.00,
    ),
    const DepartmentBudget(
      departmentName: 'Product',
      totalBudget: 100000.00,
      usedBudget: 45200.00,
    ),
    const DepartmentBudget(
      departmentName: 'Design',
      totalBudget: 60000.00,
      usedBudget: 38900.00,
    ),
    const DepartmentBudget(
      departmentName: 'Human Resources',
      totalBudget: 40000.00,
      usedBudget: 12500.00,
    ),
    const DepartmentBudget(
      departmentName: 'Finance',
      totalBudget: 50000.00,
      usedBudget: 28700.00,
    ),
  ];

  /// Get all department budgets
  Future<List<DepartmentBudget>> getDepartmentBudgets() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockBudgets);
  }

  /// Get budget for specific department
  Future<DepartmentBudget?> getBudgetByDepartment(String department) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _mockBudgets
          .firstWhere((budget) => budget.departmentName == department);
    } catch (e) {
      return null;
    }
  }

  /// Get total budget across all departments
  Future<double> getTotalBudget() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockBudgets.fold<double>(
        0.0, (sum, budget) => sum + budget.totalBudget,);
  }

  /// Get total used budget across all departments
  Future<double> getTotalUsedBudget() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockBudgets.fold<double>(
        0.0, (sum, budget) => sum + budget.usedBudget,);
  }

  /// Get total remaining budget across all departments
  Future<double> getTotalRemainingBudget() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockBudgets.fold<double>(
        0.0, (sum, budget) => sum + budget.remainingBudget,);
  }

  /// Get category breakdown (mock data for pie chart)
  Future<Map<String, double>> getCategoryBreakdown() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return {
      'Travel': 28500.00,
      'Equipment': 45200.00,
      'Software': 32100.00,
      'Marketing': 58700.00,
      'Training': 18900.00,
      'Cloud Services': 24300.00,
      'Entertainment': 12800.00,
      'Office Supplies': 9500.00,
    };
  }

  /// Get monthly expense trends (mock data for bar chart)
  Future<Map<String, double>> getMonthlyTrends() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return {
      _getMonthName(now.month - 5): 45000.00,
      _getMonthName(now.month - 4): 52000.00,
      _getMonthName(now.month - 3): 48500.00,
      _getMonthName(now.month - 2): 61000.00,
      _getMonthName(now.month - 1): 58700.00,
      _getMonthName(now.month): 64200.00,
    };
  }

  /// Get departments exceeding budget
  Future<List<DepartmentBudget>> getDepartmentsExceedingBudget() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockBudgets.where((budget) => budget.isExceeded).toList();
  }

  /// Get departments in warning zone (>= 70% usage)
  Future<List<DepartmentBudget>> getDepartmentsInWarning() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockBudgets.where((budget) => budget.isInWarning).toList();
  }

  /// Get departments in danger zone (>= 90% usage)
  Future<List<DepartmentBudget>> getDepartmentsInDanger() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _mockBudgets.where((budget) => budget.isInDanger).toList();
  }

  /// Helper method to get month name
  String _getMonthName(int month) {
    // Normalize month to 1-12 range
    final normalizedMonth = ((month - 1) % 12) + 1;
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
    return months[normalizedMonth - 1];
  }
}
