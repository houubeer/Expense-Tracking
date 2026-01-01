import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/view_models/owner_dashboard_view_model.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/company_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/manager_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/subscription_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/platform_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/services/manager_approval_service.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/services/expense_analytics_service.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/services/subscription_metrics_service.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/widgets/layout/page_header.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/widgets/cards/kpi_summary_card.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/widgets/lists/pending_manager_table.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/widgets/lists/active_managers_table.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/widgets/charts/expense_category_pie_chart.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/widgets/charts/platform_growth_line_chart.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/widgets/cards/audit_timeline_item.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';

/// Owner/Super Admin Dashboard Screen
/// Displays platform-wide KPIs, manager approvals, analytics, and audit logs
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late final OwnerDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    
    // Initialize repositories
    final companyRepo = CompanyRepository();
    final managerRepo = ManagerRepository();
    final subscriptionRepo = SubscriptionRepository();
    final expenseRepo = PlatformExpenseRepository();
    
    // Initialize services
    final approvalService = ManagerApprovalService(managerRepo);
    final analyticsService = ExpenseAnalyticsService(expenseRepo);
    final metricsService = SubscriptionMetricsService(subscriptionRepo);
    
    // Initialize view model
    _viewModel = OwnerDashboardViewModel(
      companyRepository: companyRepo,
      managerRepository: managerRepo,
      subscriptionRepository: subscriptionRepo,
      expenseRepository: expenseRepo,
      approvalService: approvalService,
      analyticsService: analyticsService,
      metricsService: metricsService,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Consumer<OwnerDashboardViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(
                  child: Text('Error: ${viewModel.error}'),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PageHeader(
                      title: 'Owner Dashboard',
                      subtitle: 'Platform-wide overview and management',
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // KPI Cards Grid (3x2)
                    _buildKpiGrid(viewModel),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Pending Manager Approvals
                    _buildPendingApprovals(viewModel),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Active Managers and Charts
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildActiveManagers(viewModel),
                        ),
                        const SizedBox(width: AppSpacing.xl),
                        Expanded(
                          child: _buildAnalytics(viewModel),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Audit Timeline
                    _buildAuditTimeline(viewModel),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKpiGrid(OwnerDashboardViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.xl,
          children: [
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.business,
                title: 'Total Companies',
                value: viewModel.totalCompanies.toString(),
                color: colorScheme.primary,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.supervisor_account,
                title: 'Total Managers',
                value: viewModel.totalManagers.toString(),
                color: colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.people,
                title: 'Total Employees',
                value: viewModel.totalEmployees.toString(),
                color: colorScheme.tertiary,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.attach_money,
                title: 'Total Expenses',
                value: '\$${viewModel.totalExpenses.toStringAsFixed(2)}',
                color: colorScheme.error,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.pending_actions,
                title: 'Pending Approvals',
                value: viewModel.pendingApprovals.toString(),
                color: Colors.orange,
                subtitle: 'Managers awaiting approval',
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.trending_up,
                title: 'Monthly Growth',
                value: '${viewModel.monthlyGrowth.toStringAsFixed(1)}%',
                color: viewModel.monthlyGrowth >= 0 ? colorScheme.tertiary : colorScheme.error,
                subtitle: 'Platform expense growth',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPendingApprovals(OwnerDashboardViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Manager Requests',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 400,
          child: PendingManagerTable(
            managers: viewModel.getPendingManagers(),
            onApprove: (id) => _handleApprove(viewModel, id),
            onReject: (id) => _handleReject(viewModel, id),
            onView: (id) => _handleViewManager(id),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveManagers(OwnerDashboardViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Managers',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 400,
          child: ActiveManagersTable(
            managers: viewModel.getActiveManagers(),
            onView: (id) => _handleViewManager(id),
            onSuspend: (id) => _handleSuspend(viewModel, id),
            onDelete: (id) => _handleDelete(viewModel, id),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalytics(OwnerDashboardViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ExpenseCategoryPieChart(
            categoryData: viewModel.getExpenseCategoryBreakdown(),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 200,
          child: PlatformGrowthLineChart(
            monthlyData: viewModel.getMonthlyTrend(),
          ),
        ),
      ],
    );
  }

  Widget _buildAuditTimeline(OwnerDashboardViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    final auditLogs = viewModel.getAuditLogs();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (auditLogs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Text('No recent activity'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auditLogs.length > 10 ? 10 : auditLogs.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return AuditTimelineItem(auditLog: auditLogs[index]);
            },
          ),
      ],
    );
  }

  Future<void> _handleApprove(OwnerDashboardViewModel viewModel, String id) async {
    try {
      await viewModel.approveManager(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manager approved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleReject(OwnerDashboardViewModel viewModel, String id) async {
    // Show dialog to get rejection reason
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _RejectDialog(),
    );
    
    if (reason != null && reason.isNotEmpty) {
      try {
        await viewModel.rejectManager(id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manager rejected')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleSuspend(OwnerDashboardViewModel viewModel, String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _SuspendDialog(),
    );
    
    if (reason != null && reason.isNotEmpty) {
      try {
        await viewModel.suspendManager(id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manager suspended')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleDelete(OwnerDashboardViewModel viewModel, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this manager? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await viewModel.deleteManager(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Manager deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _handleViewManager(String id) {
    // TODO: Implement manager profile view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manager profile view - Coming soon')),
    );
  }
}

class _RejectDialog extends StatefulWidget {
  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Manager'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Reason for rejection',
          hintText: 'Enter reason...',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

class _SuspendDialog extends StatefulWidget {
  @override
  State<_SuspendDialog> createState() => _SuspendDialogState();
}

class _SuspendDialogState extends State<_SuspendDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suspend Manager'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Reason for suspension',
          hintText: 'Enter reason...',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Suspend'),
        ),
      ],
    );
  }
}
