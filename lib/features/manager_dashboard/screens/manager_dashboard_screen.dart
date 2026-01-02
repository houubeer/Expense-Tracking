import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/dashboard_layout.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/page_header.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/summary_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/employee_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/budget_usage_card.dart';

import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/lists/expense_approval_list.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/lists/reimbursement_table.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/forms/add_employee_form.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/dialogs/expense_details_dialog.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/dialogs/add_comment_dialog.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/view_models/manager_dashboard_view_model.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/employee_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/expense_approval_service.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/budget_calculation_service.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/employee_model.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/models/expense_model.dart';

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
  late final ManagerDashboardViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize view model with dependencies
    _viewModel = ManagerDashboardViewModel(
      EmployeeRepository(),
      ExpenseRepository(),
      BudgetRepository(),
      ExpenseApprovalService(),
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

                  // Pending Expense Approvals
                  _buildPendingApprovals(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Budget Monitoring
                  _buildBudgetMonitoring(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Reimbursements
                  ReimbursementTable(
                    onExportExcel: () => _showMessage('Export Excel'),
                    onExportPdf: () => _showMessage('Export PDF'),
                  ),
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
          title: AppLocalizations.of(context)!.kpiTotalEmployees,
          value: '${stats['totalEmployees']}',
          color: colorScheme.primary,
          subtitle:
              '${stats['activeEmployees']} ${AppLocalizations.of(context)!.active}',
        ),
        SummaryCard(
          icon: Icons.attach_money,
          title: AppLocalizations.of(context)!.kpiTotalExpenses,
          value:
              '${(stats['totalExpensesThisMonth'] as double).toStringAsFixed(0)} DZD',
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
              '${(stats['remainingBudget'] as double).toStringAsFixed(0)} DZD ${AppLocalizations.of(context)!.labelRemaining}',
        ),
      ],
    );
  }

  Widget _buildEmployeeManagement(ManagerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.labelEmployeeManagement,
              style: AppTextStyles.heading2,
            ),
            Row(
              children: [
                // Search
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.hintSearchEmployees,
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
                  hint: Text(AppLocalizations.of(context)!.labelDepartment),
                  items: [
                    DropdownMenuItem(
                      child: Text(
                          AppLocalizations.of(context)!.filterAllDepartments),
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
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    ),
                  ],
                  onChanged: viewModel.setDepartmentFilter,
                ),
                const SizedBox(width: AppSpacing.md),
                // Status filter
                DropdownButton<EmployeeStatus?>(
                  value: viewModel.statusFilter,
                  hint: Text(AppLocalizations.of(context)!.labelStatus),
                  items: [
                    DropdownMenuItem(
                        child: Text(
                            AppLocalizations.of(context)!.filterAllStatuses)),
                    DropdownMenuItem(
                      value: EmployeeStatus.active,
                      child: Text(AppLocalizations.of(context)!.active),
                    ),
                    DropdownMenuItem(
                      value: EmployeeStatus.suspended,
                      child: Text(
                          AppLocalizations.of(context)!.labelStatusSuspended),
                    ),
                  ],
                  onChanged: viewModel.setStatusFilter,
                ),
                const SizedBox(width: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => _showAddEmployeeDialog(context, viewModel),
                  icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                  label: Text(AppLocalizations.of(context)!.labelAddEmployee),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        // Employee cards grid
        GridView.builder(
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
    );
  }

  Widget _buildPendingApprovals(ManagerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.labelPendingExpenseApprovals,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.lg),
        ExpenseApprovalList(
          expenses: viewModel.pendingExpenses,
          onApprove: (id) async {
            final success = await viewModel.approveExpense(id);
            if (success)
              _showMessage(AppLocalizations.of(context)!.msgExpenseApproved);
          },
          onReject: (id) async {
            final success =
                await viewModel.rejectExpense(id, 'Budget exceeded');
            if (success)
              _showMessage(AppLocalizations.of(context)!.msgExpenseRejected);
          },
          onComment: (id) => _showAddCommentDialogById(context, viewModel, id),
          onViewDetails: (expense) =>
              _showExpenseDetailsDialog(context, viewModel, expense),
        ),
      ],
    );
  }

  Widget _buildBudgetMonitoring(ManagerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.labelBudgetMonitoring,
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.lg),
        GridView.builder(
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
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddEmployeeDialog(
    BuildContext context,
    ManagerDashboardViewModel viewModel,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AddEmployeeForm(
        onSubmit: (employee) async {
          await viewModel.addEmployee(employee);
          if (mounted) {
            _showMessage(
                AppLocalizations.of(context)!.msgEmployeeAdded(employee.name));
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
          if (success && mounted)
            _showMessage(AppLocalizations.of(context)!.msgExpenseApproved);
        },
        onReject: () async {
          Navigator.of(context).pop();
          final success = await viewModel.rejectExpense(expense.id, 'Rejected');
          if (success && mounted)
            _showMessage(AppLocalizations.of(context)!.msgExpenseRejected);
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
          if (mounted)
            _showMessage(AppLocalizations.of(context)!.msgCommentAdded);
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
        _showMessage(
            AppLocalizations.of(context)!.msgViewDetailsFor(employee.name));
        break;
      case 'suspend':
        if (employee.status == EmployeeStatus.active) {
          _showConfirmDialog(
            context,
            AppLocalizations.of(context)!.dialogTitleSuspendEmployee,
            AppLocalizations.of(context)!
                .dialogDescSuspendEmployee(employee.name),
            () async {
              await viewModel.suspendEmployee(employee.id);
              if (mounted) {
                _showMessage(AppLocalizations.of(context)!
                    .msgEmployeeSuspended(employee.name));
              }
            },
          );
        } else {
          viewModel.activateEmployee(employee.id).then((_) {
            if (mounted) {
              _showMessage(AppLocalizations.of(context)!
                  .msgEmployeeActivated(employee.name));
            }
          });
        }
        break;
      case 'remove':
        _showConfirmDialog(
          context,
          AppLocalizations.of(context)!.dialogTitleRemoveEmployee,
          AppLocalizations.of(context)!.dialogDescRemoveEmployee(employee.name),
          () async {
            await viewModel.removeEmployee(employee.id);
            if (mounted) {
              _showMessage(AppLocalizations.of(context)!
                  .msgEmployeeRemoved(employee.name));
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
