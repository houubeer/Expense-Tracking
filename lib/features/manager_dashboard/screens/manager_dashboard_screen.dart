import 'package:expense_tracking_desktop_app/features/manager_dashboard/view_models/manager_dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/dashboard_layout.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/page_header.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/summary_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/employee_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/budget_usage_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/dialogs/employee_details_dialog.dart';

import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/lists/reimbursement_table.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/forms/add_employee_form.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/dialogs/expense_details_dialog.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/dialogs/add_comment_dialog.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/view_models/manager_dashboard_view_model.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/employee_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/audit_log_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/expense_approval_service.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/budget_calculation_service.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/employee_model.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/expense_model.dart';

class ManagerDashboardScreen extends StatefulWidget {
  final void Function(String) onNavigate;

  const ManagerDashboardScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  late final ManagerDashboardViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize view model with dependencies
    // Note: In production, these should be injected via dependency injection
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
    _viewModel.loadDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                    title: AppStrings.titleManagerDashboard,
                    subtitle: AppStrings.descManagerDashboard,
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
      childAspectRatio: 1.9, // Reduced from 3.0 to make cards taller
      children: [
        SummaryCard(
          icon: Icons.people,
          title: 'Total Employees',
          value: '${stats['totalEmployees']}',
          color: colorScheme.primary,
          subtitle: '${stats['activeEmployees']} active',
        ),
        SummaryCard(
          icon: Icons.attach_money,
          title: 'Expenses (Month)',
          value:
              '${(stats['totalExpensesThisMonth'] as double).toStringAsFixed(0)} DZD',
          color: colorScheme.tertiary,
        ),
        SummaryCard(
          icon: Icons.pending_actions,
          title: 'Pending',
          value: '${stats['pendingApprovals']}',
          color: Colors.orange,
        ),
        SummaryCard(
          icon: Icons.check_circle,
          title: 'Approved',
          value: '${stats['approvedExpenses']}',
          color: Colors.green,
        ),
        SummaryCard(
          icon: Icons.cancel,
          title: 'Rejected',
          value: '${stats['rejectedExpenses']}',
          color: Colors.red,
        ),
        SummaryCard(
          icon: Icons.account_balance_wallet,
          title: 'Budget',
          value:
              '${(stats['usedBudget'] as double).toStringAsFixed(0)} / ${(stats['totalBudget'] as double).toStringAsFixed(0)}',
          color: colorScheme.secondary,
          subtitle:
              '${(stats['remainingBudget'] as double).toStringAsFixed(0)} DZD left',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Employee Management', style: AppTextStyles.heading2),
              Row(
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
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      onChanged: viewModel.setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Department filter
                  DropdownButton<String?>(
                    value: viewModel.departmentFilter,
                    hint: const Text('Department'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All Departments')),
                      ...[
                        'Engineering',
                        'Marketing',
                        'Sales',
                        'Product',
                        'Design',
                        'Human Resources',
                        'Finance'
                      ].map((dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept))),
                    ],
                    onChanged: viewModel.setDepartmentFilter,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Status filter
                  DropdownButton<EmployeeStatus?>(
                    value: viewModel.statusFilter,
                    hint: const Text('Status'),
                    items: const [
                      DropdownMenuItem(
                          value: null, child: Text('All Statuses')),
                      DropdownMenuItem(
                          value: EmployeeStatus.active, child: Text('Active')),
                    ],
                    onChanged: viewModel.setStatusFilter,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () => _showAddEmployeeDialog(context, viewModel),
                    icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                    label: const Text('Add Employee'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Show either a grid or a placeholder if empty
          viewModel.filteredEmployees.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
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
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddEmployeeDialog(
      BuildContext context, ManagerDashboardViewModel viewModel) {
    showDialog<void>(
      context: context,
      builder: (context) => AddEmployeeForm(
        onSubmit: (employee) async {
          await viewModel.addEmployee(employee);
          if (mounted) {
            _showMessage('Employee ${employee.name} added successfully');
          }
        },
      ),
    );
  }

  void _showExpenseDetailsDialog(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
    ManagerExpense expense,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => ExpenseDetailsDialog(
        expense: expense,
        onApprove: () async {
          Navigator.of(context).pop();
          final success = await viewModel.approveExpense(expense.id);
          if (success && mounted) _showMessage('Expense approved');
        },
        onReject: () async {
          Navigator.of(context).pop();
          final success = await viewModel.rejectExpense(expense.id, 'Rejected');
          if (success && mounted) _showMessage('Expense rejected');
        },
        onAddComment: () {
          Navigator.of(context).pop();
          _showAddCommentDialogByExpense(context, viewModel, expense);
        },
      ),
    );
  }

  void _showAddCommentDialogById(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
    String expenseId,
  ) {
    final expense = viewModel.pendingExpenses.firstWhere(
      (e) => e.id == expenseId,
      orElse: () => viewModel.pendingExpenses.first,
    );
    _showAddCommentDialogByExpense(context, viewModel, expense);
  }

  void _showAddCommentDialogByExpense(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
    ManagerExpense expense,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AddCommentDialog(
        expenseId: expense.id,
        employeeName: expense.employeeName,
        onSubmit: (comment) async {
          await viewModel.addComment(expense.id, comment);
          if (mounted) _showMessage('Comment added successfully');
        },
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
          'Remove Employee',
          'Are you sure you want to remove ${employee.name}? This action cannot be undone.',
          () async {
            await viewModel.removeEmployee(employee.id);
            if (mounted) {
              _showMessage('${employee.name} removed');
            }
          },
        );
        break;
    }
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
            child: const Text(AppStrings.btnCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
