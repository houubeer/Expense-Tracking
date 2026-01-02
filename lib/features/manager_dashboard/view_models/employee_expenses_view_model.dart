import 'package:flutter/foundation.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/expense_model.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/budget_calculation_service.dart';

/// View model for Employee Expenses screen
/// Manages expense data, filters, and analytics
class EmployeeExpensesViewModel extends ChangeNotifier {

  EmployeeExpensesViewModel(
    this._expenseRepository,
    this._budgetRepository,
    this._calculationService,
  );
  final ExpenseRepository _expenseRepository;
  final BudgetRepository _budgetRepository;
  final BudgetCalculationService _calculationService;

  // State properties
  List<ManagerExpense> _expenses = [];
  Map<String, double> _categoryBreakdown = {};
  Map<String, double> _monthlyTrends = {};

  // Filter state
  String? _categoryFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ManagerExpense> get expenses => _expenses;
  Map<String, double> get categoryBreakdown => _categoryBreakdown;
  Map<String, double> get monthlyTrends => _monthlyTrends;
  String? get categoryFilter => _categoryFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get filtered expenses
  List<ManagerExpense> get filteredExpenses {
    var filtered = _expenses;

    // Apply category filter
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      filtered =
          filtered.where((exp) => exp.category == _categoryFilter).toList();
    }

    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((exp) {
        return exp.date.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
            exp.date.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  /// Get summary statistics
  Map<String, dynamic> get summaryStats {
    final total = _calculationService.getTotalAmount(_expenses);
    final pending = _calculationService.getTotalAmount(
      _expenses.where((e) => e.status == ExpenseStatus.pending).toList(),
    );
    final approved = _calculationService.getTotalAmount(
      _expenses.where((e) => e.status == ExpenseStatus.approved).toList(),
    );
    final rejected = _calculationService.getTotalAmount(
      _expenses.where((e) => e.status == ExpenseStatus.rejected).toList(),
    );

    final pendingCount =
        _expenses.where((e) => e.status == ExpenseStatus.pending).length;
    final approvedCount =
        _expenses.where((e) => e.status == ExpenseStatus.approved).length;
    final rejectedCount =
        _expenses.where((e) => e.status == ExpenseStatus.rejected).length;

    return {
      'totalAmount': total,
      'pendingAmount': pending,
      'approvedAmount': approved,
      'rejectedAmount': rejected,
      'totalCount': _expenses.length,
      'pendingCount': pendingCount,
      'approvedCount': approvedCount,
      'rejectedCount': rejectedCount,
    };
  }

  /// Load expenses data
  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load expenses and analytics data
      final results = await Future.wait([
        _expenseRepository.getAllExpenses(),
        _budgetRepository.getCategoryBreakdown(),
        _budgetRepository.getMonthlyTrends(),
      ]);

      _expenses = results[0] as List<ManagerExpense>;
      _categoryBreakdown = results[1] as Map<String, double>;
      _monthlyTrends = results[2] as Map<String, double>;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load expenses: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter by category
  void filterByCategory(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  /// Filter by date range
  void filterByDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  /// Clear date range filter
  void clearDateRange() {
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Get category distribution for pie chart
  Map<String, double> getCategoryDistribution() {
    return _calculationService.getCategoryDistribution(filteredExpenses);
  }

  /// Get monthly trends for bar chart
  Map<String, double> getMonthlyTrends() {
    return _calculationService.getMonthlyDistribution(filteredExpenses);
  }

  /// Get top spending categories
  List<MapEntry<String, double>> getTopCategories({int limit = 5}) {
    return _calculationService.getTopSpendingCategories(
      filteredExpenses,
      limit: limit,
    );
  }

  /// Clear all filters
  void clearFilters() {
    _categoryFilter = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadExpenses();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
