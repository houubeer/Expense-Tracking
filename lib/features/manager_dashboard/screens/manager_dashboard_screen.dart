import 'package:expense_tracking_desktop_app/features/manager_dashboard/view_models/manager_dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/dashboard_layout.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/page_header.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/summary_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/employee_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/budget_usage_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/dialogs/employee_details_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';

import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/lists/reimbursement_table.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/forms/add_employee_form.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/employee_model.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/employee_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/audit_log_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/expense_approval_service.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/budget_calculation_service.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({
    required this.onNavigate,
    super.key,
  });
  final void Function(String) onNavigate;

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  ManagerDashboardViewModel? _viewModel;
  final TextEditingController _searchController = TextEditingController();
  bool _isCheckingAccess = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final supabase = SupabaseService();
      final user = supabase.currentUser;

      if (user != null) {
        final profile = await supabase.getUserProfile(user.id);
        if (profile != null && profile.role.value == 'manager') {
          _initViewModel();
          if (mounted) {
            setState(() {
              _hasAccess = true;
              _isCheckingAccess = false;
            });
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Error checking access: $e');
    }

    if (mounted) {
      setState(() {
        _hasAccess = false;
        _isCheckingAccess = false;
      });
    }
  }

  void _initViewModel() {
    final supabaseService = SupabaseService();
    final auditLogRepo = AuditLogRepository(supabaseService);
    _viewModel = ManagerDashboardViewModel(
      EmployeeRepository(supabaseService, auditLogRepo),
      ExpenseRepository(supabaseService, auditLogRepo),
      BudgetRepository(supabaseService),
      auditLogRepo,
      ExpenseApprovalService(
        ExpenseRepository(supabaseService, auditLogRepo),
      ),
      BudgetCalculationService(),
    );
    // Load initial data
    _viewModel!.loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('You do not have permission to view this dashboard.\nOnly managers can access this area.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: DashboardLayout(
        child: Consumer<ManagerDashboardViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: viewModel.loadDashboardData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  PageHeader(
                    title: AppLocalizations.of(context)!.titleManagerDashboard,
                    subtitle:
                        AppLocalizations.of(context)!.descManagerDashboard,
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Summary Cards (3x2 grid)
                  _buildSummaryCards(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Employee Management Section
                  _buildEmployeeManagement(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Budget Monitoring
                  _buildBudgetMonitoring(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Reimbursements
                  ReimbursementTable(expenses: viewModel.reimbursableExpenses),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ManagerDashboardViewModel viewModel) {
    final stats = viewModel.summaryStats;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      childAspectRatio: 1.5, // Reduced to give more height for card content
      children: [
        SummaryCard(
          icon: Icons.people,
          title: AppLocalizations.of(context)!.kpiTotalEmployees,
          value: '${stats['totalEmployees']}',
          color: colorScheme.primary,
          subtitle:
              '${stats['activeEmployees']} ${AppLocalizations.of(context)!.labelStatusActive}',
        ),
        SummaryCard(
          icon: Icons.attach_money,
          title: AppLocalizations.of(context)!.kpiTotalExpenses,
          value:
              '${(stats['totalExpensesThisMonth'] as double).toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          color: colorScheme.tertiary,
        ),
        SummaryCard(
          icon: Icons.pending_actions,
          title: AppLocalizations.of(context)!.kpiPendingApprovals,
          value: '${stats['pendingApprovals']}',
          color: Colors.orange,
        ),
        SummaryCard(
          icon: Icons.check_circle,
          title: AppLocalizations.of(context)!.statusGood,
          value: '${stats['approvedExpenses']}',
          color: Colors.green,
        ),
        SummaryCard(
          icon: Icons.cancel,
          title: AppLocalizations.of(context)!.msgExpenseRejected,
          value: '${stats['rejectedExpenses']}',
          color: Colors.red,
        ),
        SummaryCard(
          icon: Icons.account_balance_wallet,
          title: AppLocalizations.of(context)!.labelBudget,
          value:
              '${(stats['usedBudget'] as double).toStringAsFixed(0)} / ${(stats['totalBudget'] as double).toStringAsFixed(0)}',
          color: colorScheme.secondary,
          subtitle:
              '${(stats['remainingBudget'] as double).toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency} ${AppLocalizations.of(context)!.labelRemaining}',
        ),
      ],
    );
  }

  Widget _buildEmployeeManagement(ManagerDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Text('Employee Management', style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.md),
          // Controls row - using Wrap for responsive layout
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search employees...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onChanged: viewModel.setSearchQuery,
                ),
              ),
              // Department filter
              DropdownButton<String?>(
                value: viewModel.departmentFilter,
                hint: const Text('Department'),
                items: [
                  const DropdownMenuItem(
                    child: Text('All Departments'),
                  ),
                  ...[
                    'Engineering',
                    'Marketing',
                    'Sales',
                    'Product',
                    'Design',
                    'Human Resources',
                    'Finance',
                  ].map(
                    (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
                  ),
                ],
                onChanged: viewModel.setDepartmentFilter,
              ),
              // Status filter
              DropdownButton<EmployeeStatus?>(
                value: viewModel.statusFilter,
                hint: const Text('Status'),
                items: const [
                  DropdownMenuItem(child: Text('All Statuses')),
                  DropdownMenuItem(
                    value: EmployeeStatus.active,
                    child: Text('Active'),
                  ),
                ],
                onChanged: viewModel.setStatusFilter,
              ),
              FilledButton.icon(
                onPressed: () => _showAddEmployeeDialog(context, viewModel),
                icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                label: const Text('Add Employee'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Show either a grid or a placeholder if empty
          viewModel.filteredEmployees.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      'No employees found.',
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: viewModel.filteredEmployees.length,
                  itemBuilder: (context, index) {
                    return EmployeeCard(
                      employee: viewModel.filteredEmployees[index],
                      onMenuAction: (action) => _handleEmployeeAction(
                        context,
                        viewModel,
                        viewModel.filteredEmployees[index],
                        action,
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildBudgetMonitoring(ManagerDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Monitoring', style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.lg),
          viewModel.budgets.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      'No budgets available.',
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 3,
                  ),
                  itemCount: viewModel.budgets.length,
                  itemBuilder: (context, index) {
                    return BudgetUsageCard(budget: viewModel.budgets[index]);
                  },
                ),
        ],
      ),
    );
  }

  void _handleEmployeeAction(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
    Employee employee,
    String action,
  ) {
    switch (action) {
      case 'view':
        showDialog<void>(
          context: context,
          builder: (context) => EmployeeDetailsDialog(
            employee: employee,
          ),
        );
        break;

      case 'remove':
        _showConfirmDialog(
          context,
          AppLocalizations.of(context)!.dialogTitleRemoveEmployee,
          AppLocalizations.of(context)!.dialogDescRemoveEmployee(employee.name),
          () async {
            final messenger = ScaffoldMessenger.of(context);
            final loc = AppLocalizations.of(context)!;
            await viewModel.removeEmployee(employee.id);
            messenger.showSnackBar(
              SnackBar(content: Text(loc.msgEmployeeRemoved(employee.name))),
            );
          },
        );
        break;
    }
  }

  void _showAddEmployeeDialog(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AddEmployeeForm(
        onSubmit: (employee) async {
          final messenger = ScaffoldMessenger.of(context);
          final loc = AppLocalizations.of(context)!;
          await viewModel.addEmployee(employee);
          messenger.showSnackBar(
            SnackBar(content: Text(loc.msgEmployeeAdded(employee.name))),
          );
        },
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(AppLocalizations.of(context)!.btnConfirm),
          ),
        ],
      ),
    );
  }
}
