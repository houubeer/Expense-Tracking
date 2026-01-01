import '../models/expense_model.dart';

/// Repository providing mock expense data for manager approval workflow
class ExpenseRepository {
  // Mock expense data
  static final List<ManagerExpense> _mockExpenses = [
    ManagerExpense(
      id: 'exp001',
      employeeId: 'emp001',
      employeeName: 'Sarah Johnson',
      amount: 12500.00,
      category: 'Travel',
      date: DateTime.now().subtract(const Duration(days: 2)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'Flight tickets to Paris for client meeting',
    ),
    ManagerExpense(
      id: 'exp002',
      employeeId: 'emp002',
      employeeName: 'Michael Chen',
      amount: 3200.00,
      category: 'Equipment',
      date: DateTime.now().subtract(const Duration(days: 1)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'New laptop for development work',
    ),
    ManagerExpense(
      id: 'exp003',
      employeeId: 'emp003',
      employeeName: 'Emily Rodriguez',
      amount: 850.00,
      category: 'Software',
      date: DateTime.now().subtract(const Duration(days: 3)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Adobe Creative Cloud subscription',
    ),
    ManagerExpense(
      id: 'exp004',
      employeeId: 'emp004',
      employeeName: 'David Kim',
      amount: 4500.00,
      category: 'Marketing',
      date: DateTime.now().subtract(const Duration(days: 5)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'Facebook Ads campaign budget',
    ),
    ManagerExpense(
      id: 'exp005',
      employeeId: 'emp005',
      employeeName: 'Jessica Williams',
      amount: 2100.00,
      category: 'Entertainment',
      date: DateTime.now().subtract(const Duration(days: 7)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Client dinner at Le Gourmet',
    ),
    ManagerExpense(
      id: 'exp006',
      employeeId: 'emp006',
      employeeName: 'Robert Taylor',
      amount: 1800.00,
      category: 'Cloud Services',
      date: DateTime.now().subtract(const Duration(days: 4)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'AWS infrastructure costs',
    ),
    ManagerExpense(
      id: 'exp007',
      employeeId: 'emp007',
      employeeName: 'Amanda Brown',
      amount: 650.00,
      category: 'Training',
      date: DateTime.now().subtract(const Duration(days: 10)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'HR certification course',
    ),
    ManagerExpense(
      id: 'exp008',
      employeeId: 'emp008',
      employeeName: 'Christopher Lee',
      amount: 5200.00,
      category: 'Travel',
      date: DateTime.now().subtract(const Duration(days: 15)),
      receiptUrl: null,
      status: ExpenseStatus.rejected,
      comment: 'Travel not pre-approved',
      description: 'Unauthorized conference trip',
    ),
    ManagerExpense(
      id: 'exp009',
      employeeId: 'emp009',
      employeeName: 'Maria Garcia',
      amount: 420.00,
      category: 'Office Supplies',
      date: DateTime.now().subtract(const Duration(days: 6)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Notebooks and pens for team',
    ),
    ManagerExpense(
      id: 'exp010',
      employeeId: 'emp010',
      employeeName: 'James Anderson',
      amount: 1500.00,
      category: 'Software',
      date: DateTime.now().subtract(const Duration(days: 8)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'Testing automation tools license',
    ),
    ManagerExpense(
      id: 'exp011',
      employeeId: 'emp011',
      employeeName: 'Lisa Martinez',
      amount: 980.00,
      category: 'Training',
      date: DateTime.now().subtract(const Duration(days: 12)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Financial modeling workshop',
    ),
    ManagerExpense(
      id: 'exp012',
      employeeId: 'emp012',
      employeeName: 'Daniel Wilson',
      amount: 3400.00,
      category: 'Travel',
      date: DateTime.now().subtract(const Duration(days: 9)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'Sales conference in Dubai',
    ),
    ManagerExpense(
      id: 'exp013',
      employeeId: 'emp001',
      employeeName: 'Sarah Johnson',
      amount: 750.00,
      category: 'Equipment',
      date: DateTime.now().subtract(const Duration(days: 14)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Wireless keyboard and mouse',
    ),
    ManagerExpense(
      id: 'exp014',
      employeeId: 'emp002',
      employeeName: 'Michael Chen',
      amount: 2200.00,
      category: 'Entertainment',
      date: DateTime.now().subtract(const Duration(days: 11)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'Team building event',
    ),
    ManagerExpense(
      id: 'exp015',
      employeeId: 'emp004',
      employeeName: 'David Kim',
      amount: 1100.00,
      category: 'Marketing',
      date: DateTime.now().subtract(const Duration(days: 13)),
      receiptUrl: null,
      status: ExpenseStatus.rejected,
      comment: 'Budget exceeded for this month',
      description: 'LinkedIn Ads campaign',
    ),
    ManagerExpense(
      id: 'exp016',
      employeeId: 'emp006',
      employeeName: 'Robert Taylor',
      amount: 890.00,
      category: 'Cloud Services',
      date: DateTime.now().subtract(const Duration(days: 16)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Database hosting fees',
    ),
    ManagerExpense(
      id: 'exp017',
      employeeId: 'emp003',
      employeeName: 'Emily Rodriguez',
      amount: 1650.00,
      category: 'Equipment',
      date: DateTime.now().subtract(const Duration(days: 18)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Drawing tablet for design work',
    ),
    ManagerExpense(
      id: 'exp018',
      employeeId: 'emp005',
      employeeName: 'Jessica Williams',
      amount: 5800.00,
      category: 'Travel',
      date: DateTime.now().subtract(const Duration(days: 20)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'Business trip to New York',
    ),
    ManagerExpense(
      id: 'exp019',
      employeeId: 'emp009',
      employeeName: 'Maria Garcia',
      amount: 320.00,
      category: 'Software',
      date: DateTime.now().subtract(const Duration(days: 17)),
      receiptUrl: null,
      status: ExpenseStatus.pending,
      description: 'Grammarly Premium subscription',
    ),
    ManagerExpense(
      id: 'exp020',
      employeeId: 'emp010',
      employeeName: 'James Anderson',
      amount: 2900.00,
      category: 'Training',
      date: DateTime.now().subtract(const Duration(days: 22)),
      receiptUrl: null,
      status: ExpenseStatus.approved,
      description: 'QA automation bootcamp',
    ),
  ];

  /// Get all expenses
  Future<List<ManagerExpense>> getAllExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_mockExpenses);
  }

  /// Get pending expenses
  Future<List<ManagerExpense>> getPendingExpenses() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockExpenses
        .where((exp) => exp.status == ExpenseStatus.pending)
        .toList();
  }

  /// Get expenses by employee ID
  Future<List<ManagerExpense>> getExpensesByEmployee(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockExpenses.where((exp) => exp.employeeId == employeeId).toList();
  }

  /// Get expenses by status
  Future<List<ManagerExpense>> getExpensesByStatus(
      ExpenseStatus status) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockExpenses.where((exp) => exp.status == status).toList();
  }

  /// Get expenses by date range
  Future<List<ManagerExpense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockExpenses
        .where((exp) =>
            exp.date.isAfter(start.subtract(const Duration(days: 1))) &&
            exp.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  /// Get expenses by category
  Future<List<ManagerExpense>> getExpensesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockExpenses.where((exp) => exp.category == category).toList();
  }

  /// Get total expenses amount
  Future<double> getTotalExpensesAmount() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockExpenses.fold<double>(0.0, (sum, exp) => sum + exp.amount);
  }

  /// Get expense count by status
  Future<Map<ExpenseStatus, int>> getExpenseCountByStatus() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final counts = <ExpenseStatus, int>{};
    for (final status in ExpenseStatus.values) {
      counts[status] =
          _mockExpenses.where((exp) => exp.status == status).length;
    }
    return counts;
  }

  /// Get all unique categories
  Future<List<String>> getAllCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockExpenses.map((exp) => exp.category).toSet().toList()..sort();
  }

  /// Get expenses for current month
  Future<List<ManagerExpense>> getCurrentMonthExpenses() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }
}
