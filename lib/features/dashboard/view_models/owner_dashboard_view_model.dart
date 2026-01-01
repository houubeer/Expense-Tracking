import 'package:flutter/foundation.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/company_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/manager_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/subscription_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/platform_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/services/manager_approval_service.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/services/expense_analytics_service.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/services/subscription_metrics_service.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/audit_log_model.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/models/manager_model.dart';

/// ViewModel for Owner Dashboard
/// Manages dashboard state, KPIs, and user interactions
class OwnerDashboardViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepository;
  final ManagerRepository _managerRepository;
  final SubscriptionRepository _subscriptionRepository;
  final PlatformExpenseRepository _expenseRepository;
  final ManagerApprovalService _approvalService;
  final ExpenseAnalyticsService _analyticsService;
  final SubscriptionMetricsService _metricsService;

  // State properties
  int _totalCompanies = 0;
  int _totalManagers = 0;
  int _totalEmployees = 0;
  double _totalExpenses = 0.0;
  int _pendingApprovals = 0;
  double _monthlyGrowth = 0.0;
  bool _isLoading = false;
  String? _error;

  OwnerDashboardViewModel({
    required CompanyRepository companyRepository,
    required ManagerRepository managerRepository,
    required SubscriptionRepository subscriptionRepository,
    required PlatformExpenseRepository expenseRepository,
    required ManagerApprovalService approvalService,
    required ExpenseAnalyticsService analyticsService,
    required SubscriptionMetricsService metricsService,
  })  : _companyRepository = companyRepository,
        _managerRepository = managerRepository,
        _subscriptionRepository = subscriptionRepository,
        _expenseRepository = expenseRepository,
        _approvalService = approvalService,
        _analyticsService = analyticsService,
        _metricsService = metricsService {
    loadDashboardData();
  }

  // Getters
  int get totalCompanies => _totalCompanies;
  int get totalManagers => _totalManagers;
  int get totalEmployees => _totalEmployees;
  double get totalExpenses => _totalExpenses;
  int get pendingApprovals => _pendingApprovals;
  double get monthlyGrowth => _monthlyGrowth;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load dashboard data and calculate KPIs
  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load KPIs
      _totalCompanies = _companyRepository.getTotalCount();
      _totalManagers = _managerRepository.getTotalCount();
      _totalEmployees = _companyRepository.getTotalEmployees();
      _totalExpenses = _analyticsService.calculateTotalExpenses();
      _pendingApprovals = _managerRepository.getPendingCount();
      _monthlyGrowth = _analyticsService.calculateMonthlyGrowth();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh metrics (called after any data change)
  Future<void> refreshMetrics() async {
    await loadDashboardData();
  }

  /// Approve a manager
  Future<void> approveManager(String managerId) async {
    try {
      await _approvalService.approveManager(managerId);
      await refreshMetrics();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Reject a manager
  Future<void> rejectManager(String managerId, String reason) async {
    try {
      await _approvalService.rejectManager(managerId, reason);
      await refreshMetrics();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Suspend a manager
  Future<void> suspendManager(String managerId, String reason) async {
    try {
      await _approvalService.suspendManager(managerId, reason);
      await refreshMetrics();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Activate a manager
  Future<void> activateManager(String managerId) async {
    try {
      await _approvalService.activateManager(managerId);
      await refreshMetrics();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a manager
  Future<void> deleteManager(String managerId) async {
    try {
      await _approvalService.deleteManager(managerId);
      await refreshMetrics();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get pending managers
  List<Manager> getPendingManagers() {
    return _managerRepository.getPending();
  }

  /// Get active managers
  List<Manager> getActiveManagers() {
    return _managerRepository.getActive();
  }

  /// Get audit logs
  List<AuditLog> getAuditLogs() {
    return _approvalService.getAuditLogs();
  }

  /// Get expense category breakdown
  Map<String, double> getExpenseCategoryBreakdown() {
    return _analyticsService.getCategoryBreakdown();
  }

  /// Get category percentages for pie chart
  Map<String, double> getCategoryPercentages() {
    return _analyticsService.getCategoryPercentages();
  }

  /// Get monthly expense trend
  Map<String, double> getMonthlyTrend() {
    return _analyticsService.getMonthlyTrend();
  }

  /// Get subscription metrics
  dynamic getSubscriptionMetrics() {
    return _metricsService.getMetrics();
  }

  /// Get monthly revenue
  double getMonthlyRevenue() {
    return _metricsService.calculateMonthlyRevenue();
  }

  /// Get active subscriptions count
  int getActiveSubscriptions() {
    return _metricsService.getActiveSubscriptionsCount();
  }

  /// Get expired subscriptions count
  int getExpiredSubscriptions() {
    return _metricsService.getExpiredSubscriptionsCount();
  }

  /// Get upgrade activity
  int getUpgradeActivity() {
    return _metricsService.getUpgradeActivity();
  }
}
