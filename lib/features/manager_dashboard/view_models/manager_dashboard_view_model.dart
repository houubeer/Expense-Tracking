import 'package:flutter/foundation.dart';
import '../models/employee_model.dart';
import '../models/expense_model.dart';
import '../models/budget_model.dart';
import '../models/audit_log_model.dart';
import '../repositories/employee_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/budget_repository.dart';
import '../services/expense_approval_service.dart';
import '../services/budget_calculation_service.dart';

/// View model for Manager Dashboard screen
/// Manages state and orchestrates data flow between repositories/services and UI
class ManagerDashboardViewModel extends ChangeNotifier {
  final EmployeeRepository _employeeRepository;
  final ExpenseRepository _expenseRepository;
  final BudgetRepository _budgetRepository;
  final ExpenseApprovalService _approvalService;
  final BudgetCalculationService _calculationService;

  // State properties
  List<Employee> _employees = [];
  List<ManagerExpense> _pendingExpenses = [];
  List<ManagerExpense> _allExpenses = [];
  List<DepartmentBudget> _budgets = [];
  List<AuditLog> _auditLogs = [];

  // Filter state
  String _searchQuery = '';
  String? _departmentFilter;
  EmployeeStatus? _statusFilter;

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

  ManagerDashboardViewModel(
    this._employeeRepository,
    this._expenseRepository,
    this._budgetRepository,
    this._approvalService,
    this._calculationService,
  );

  // Getters
  List<Employee> get employees => _employees;
  List<ManagerExpense> get pendingExpenses => _pendingExpenses;
  List<ManagerExpense> get allExpenses => _allExpenses;
  List<DepartmentBudget> get budgets => _budgets;
  List<AuditLog> get auditLogs => _auditLogs;
  String get searchQuery => _searchQuery;
  String? get departmentFilter => _departmentFilter;
  EmployeeStatus? get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get filtered employees based on search and filters
  List<Employee> get filteredEmployees {
    var filtered = _employees;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((emp) {
        return emp.name.toLowerCase().contains(query) ||
            emp.email.toLowerCase().contains(query) ||
            emp.role.toLowerCase().contains(query);
      }).toList();
    }

    // Apply department filter
    if (_departmentFilter != null && _departmentFilter!.isNotEmpty) {
      filtered =
          filtered.where((emp) => emp.department == _departmentFilter).toList();
    }

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((emp) => emp.status == _statusFilter).toList();
    }

    return filtered;
  }

  /// Get summary statistics
  Map<String, dynamic> get summaryStats {
    final totalEmployees = _employees.length;
    final activeEmployees =
        _employees.where((e) => e.status == EmployeeStatus.active).length;

    final totalExpensesThisMonth = _calculationService.getTotalAmount(
      _allExpenses.where((exp) {
        final now = DateTime.now();
        return exp.date.year == now.year && exp.date.month == now.month;
      }).toList(),
    );

    final pendingCount = _pendingExpenses.length;
    final approvedCount =
        _allExpenses.where((e) => e.status == ExpenseStatus.approved).length;
    final rejectedCount =
        _allExpenses.where((e) => e.status == ExpenseStatus.rejected).length;

    final totalBudget = _budgets.fold(0.0, (sum, b) => sum + b.totalBudget);
    final usedBudget = _budgets.fold(0.0, (sum, b) => sum + b.usedBudget);
    final remainingBudget = totalBudget - usedBudget;

    return {
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'totalExpensesThisMonth': totalExpensesThisMonth,
      'pendingApprovals': pendingCount,
      'approvedExpenses': approvedCount,
      'rejectedExpenses': rejectedCount,
      'totalBudget': totalBudget,
      'usedBudget': usedBudget,
      'remainingBudget': remainingBudget,
    };
  }

  /// Load all dashboard data
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load data from repositories in parallel
      final results = await Future.wait([
        _employeeRepository.getAllEmployees(),
        _expenseRepository.getPendingExpenses(),
        _expenseRepository.getAllExpenses(),
        _budgetRepository.getDepartmentBudgets(),
      ]);

      _employees = results[0] as List<Employee>;
      _pendingExpenses = results[1] as List<ManagerExpense>;
      _allExpenses = results[2] as List<ManagerExpense>;
      _budgets = results[3] as List<DepartmentBudget>;

      // Get audit logs from approval service
      _auditLogs = _approvalService.getRecentAuditLogs(limit: 10);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve an expense
  Future<bool> approveExpense(String expenseId) async {
    try {
      final success = await _approvalService.approveExpense(
        expenseId,
        'manager001',
        managerName: 'Current Manager',
      );

      if (success) {
        // Update local state
        final expenseIndex =
            _pendingExpenses.indexWhere((e) => e.id == expenseId);
        if (expenseIndex != -1) {
          final expense = _pendingExpenses[expenseIndex];
          _pendingExpenses.removeAt(expenseIndex);

          // Update in all expenses list
          final allIndex = _allExpenses.indexWhere((e) => e.id == expenseId);
          if (allIndex != -1) {
            _allExpenses[allIndex] =
                expense.copyWith(status: ExpenseStatus.approved);
          }
        }

        // Refresh audit logs
        _auditLogs = _approvalService.getRecentAuditLogs(limit: 10);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to approve expense: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Reject an expense
  Future<bool> rejectExpense(String expenseId, String reason) async {
    try {
      final success = await _approvalService.rejectExpense(
        expenseId,
        'manager001',
        reason,
        managerName: 'Current Manager',
      );

      if (success) {
        // Update local state
        final expenseIndex =
            _pendingExpenses.indexWhere((e) => e.id == expenseId);
        if (expenseIndex != -1) {
          final expense = _pendingExpenses[expenseIndex];
          _pendingExpenses.removeAt(expenseIndex);

          // Update in all expenses list
          final allIndex = _allExpenses.indexWhere((e) => e.id == expenseId);
          if (allIndex != -1) {
            _allExpenses[allIndex] = expense.copyWith(
              status: ExpenseStatus.rejected,
              comment: reason,
            );
          }
        }

        // Refresh audit logs
        _auditLogs = _approvalService.getRecentAuditLogs(limit: 10);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to reject expense: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Add comment to expense
  Future<void> addComment(String expenseId, String comment) async {
    try {
      await _approvalService.addComment(expenseId, comment);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add comment: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Update department filter
  void setDepartmentFilter(String? department) {
    _departmentFilter = department;
    notifyListeners();
  }

  /// Update status filter
  void setStatusFilter(EmployeeStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _departmentFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Add new employee
  Future<void> addEmployee(Employee employee) async {
    try {
      await _employeeRepository.addEmployee(employee);
      _employees.add(employee);
      
      // Add audit log
      _auditLogs.insert(
        0,
        AuditLog(
          id: 'audit${DateTime.now().millisecondsSinceEpoch}',
          action: AuditAction.employeeAdded,
          managerName: 'Current Manager',
          timestamp: DateTime.now(),
          details: 'Added employee ${employee.name}',
        ),
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add employee: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Suspend employee
  Future<void> suspendEmployee(String employeeId) async {
    try {
      await _employeeRepository.suspendEmployee(employeeId);
      
      final index = _employees.indexWhere((emp) => emp.id == employeeId);
      if (index != -1) {
        _employees[index] = _employees[index].copyWith(
          status: EmployeeStatus.suspended,
        );
        
        // Add audit log
        _auditLogs.insert(
          0,
          AuditLog(
            id: 'audit${DateTime.now().millisecondsSinceEpoch}',
            action: AuditAction.employeeAdded,
            managerName: 'Current Manager',
            timestamp: DateTime.now(),
            details: 'Suspended employee ${_employees[index].name}',
          ),
        );
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to suspend employee: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Activate employee
  Future<void> activateEmployee(String employeeId) async {
    try {
      await _employeeRepository.activateEmployee(employeeId);
      
      final index = _employees.indexWhere((emp) => emp.id == employeeId);
      if (index != -1) {
        _employees[index] = _employees[index].copyWith(
          status: EmployeeStatus.active,
        );
        
        // Add audit log
        _auditLogs.insert(
          0,
          AuditLog(
            id: 'audit${DateTime.now().millisecondsSinceEpoch}',
            action: AuditAction.employeeAdded,
            managerName: 'Current Manager',
            timestamp: DateTime.now(),
            details: 'Activated employee ${_employees[index].name}',
          ),
        );
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to activate employee: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Remove employee
  Future<void> removeEmployee(String employeeId) async {
    try {
      final employee = _employees.firstWhere((emp) => emp.id == employeeId);
      await _employeeRepository.removeEmployee(employeeId);
      
      _employees.removeWhere((emp) => emp.id == employeeId);
      
      // Add audit log
      _auditLogs.insert(
        0,
        AuditLog(
          id: 'audit${DateTime.now().millisecondsSinceEpoch}',
          action: AuditAction.employeeAdded,
          managerName: 'Current Manager',
          timestamp: DateTime.now(),
          details: 'Removed employee ${employee.name}',
        ),
      );
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove employee: ${e.toString()}';
      notifyListeners();
    }
  }
}
