import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/dashboard_layout.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/layout/page_header.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/summary_card.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/charts/category_pie_chart.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/charts/monthly_bar_chart.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/view_models/employee_expenses_view_model.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/services/budget_calculation_service.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/repositories/audit_log_repository.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';

/// Employee Expenses Screen
/// View and manage employee expense submissions with analytics
class EmployeeExpensesScreen extends StatefulWidget {
  final void Function(String) onNavigate;

  const EmployeeExpensesScreen({
    super.key,
    required this.onNavigate,
  });

  @override
  State<EmployeeExpensesScreen> createState() => _EmployeeExpensesScreenState();
}

class _EmployeeExpensesScreenState extends State<EmployeeExpensesScreen> {
  late final EmployeeExpensesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize view model with dependencies
    // Note: In production, these should be injected via dependency injection
    final supabaseService = SupabaseService();
    _viewModel = EmployeeExpensesViewModel(
      ExpenseRepository(supabaseService, AuditLogRepository(supabaseService)),
      BudgetRepository(supabaseService),
      BudgetCalculationService(),
    );
    // Load initial data
    _viewModel.loadExpenses();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: DashboardLayout(
        child: Consumer<EmployeeExpensesViewModel>(
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
                    title: AppStrings.titleEmployeeExpenses,
                    subtitle: AppStrings.descEmployeeExpenses,
                    actionButton: FilledButton.icon(
                      onPressed: () => _showMessage('Add Expense'),
                      icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                      label: const Text(AppStrings.btnAddExpense),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Summary Cards
                  _buildSummaryCards(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Filters and Expense List
                  _buildExpenseList(viewModel),
                  const SizedBox(height: AppSpacing.xxl),

                  // Analytics Row (Pie Chart + Bar Chart)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CategoryPieChart(
                          categoryData: viewModel.getCategoryDistribution(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: MonthlyBarChart(
                          monthlyData: viewModel.monthlyTrends,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(EmployeeExpensesViewModel viewModel) {
    final stats = viewModel.summaryStats;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            icon: Icons.receipt_long,
            title: 'Total Expenses',
            value:
                '${(stats['totalAmount'] as double).toStringAsFixed(0)} ${AppStrings.currency}',
            color: colorScheme.primary,
            subtitle: '${stats['totalCount']} expenses',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: SummaryCard(
            icon: Icons.pending,
            title: 'Pending',
            value:
                '${(stats['pendingAmount'] as double).toStringAsFixed(0)} ${AppStrings.currency}',
            color: Colors.orange,
            subtitle: '${stats['pendingCount']} expenses',
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: SummaryCard(
            icon: Icons.check_circle,
            title: 'Approved',
            value:
                '${(stats['approvedAmount'] as double).toStringAsFixed(0)} ${AppStrings.currency}',
            color: Colors.green,
            subtitle: '${stats['approvedCount']} expenses',
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseList(EmployeeExpensesViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Expenses',
              style: AppTextStyles.heading2,
            ),
            Row(
              children: [
                // Category filter
                DropdownButton<String?>(
                  value: viewModel.categoryFilter,
                  hint: const Text('All Categories'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Categories')),
                    ...[
                      'Travel',
                      'Equipment',
                      'Software',
                      'Marketing',
                      'Training',
                      'Cloud Services',
                      'Entertainment',
                      'Office Supplies'
                    ].map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat))),
                  ],
                  onChanged: viewModel.filterByCategory,
                ),
                const SizedBox(width: AppSpacing.md),
                // Date range filter
                OutlinedButton.icon(
                  onPressed: () => _showDateRangePicker(viewModel),
                  icon: const Icon(Icons.date_range, size: AppSpacing.iconXs),
                  label: Text(
                    viewModel.startDate != null && viewModel.endDate != null
                        ? '${viewModel.startDate!.day}/${viewModel.startDate!.month} - ${viewModel.endDate!.day}/${viewModel.endDate!.month}'
                        : 'Date Range',
                  ),
                ),
                if (viewModel.categoryFilter != null ||
                    viewModel.startDate != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  TextButton(
                    onPressed: viewModel.clearFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  void _showDateRangePicker(EmployeeExpensesViewModel viewModel) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: viewModel.startDate != null && viewModel.endDate != null
          ? DateTimeRange(start: viewModel.startDate!, end: viewModel.endDate!)
          : null,
    );

    if (picked != null) {
      viewModel.filterByDateRange(picked.start, picked.end);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
