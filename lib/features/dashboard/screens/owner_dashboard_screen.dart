import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/l10n/app_localizations.dart';
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
                    PageHeader(
                      title: AppLocalizations.of(context)!.ownerDashboard,
                      subtitle:
                          AppLocalizations.of(context)!.subtitleOwnerDashboard,
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
                title: AppLocalizations.of(context)!.kpiTotalCompanies,
                value: viewModel.totalCompanies.toString(),
                color: colorScheme.primary,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.supervisor_account,
                title: AppLocalizations.of(context)!.kpiTotalManagers,
                value: viewModel.totalManagers.toString(),
                color: colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.people,
                title: AppLocalizations.of(context)!.kpiTotalEmployees,
                value: viewModel.totalEmployees.toString(),
                color: colorScheme.tertiary,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.attach_money,
                title: AppLocalizations.of(context)!.kpiTotalExpenses,
                value: '\$${viewModel.totalExpenses.toStringAsFixed(2)}',
                color: colorScheme.error,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.pending_actions,
                title: AppLocalizations.of(context)!.kpiPendingApprovals,
                value: viewModel.pendingApprovals.toString(),
                color: Colors.orange,
                subtitle:
                    AppLocalizations.of(context)!.kpiPendingApprovalsSubtitle,
              ),
            ),
            SizedBox(
              width: (constraints.maxWidth - AppSpacing.xl * 2) / 3,
              child: KpiSummaryCard(
                icon: Icons.trending_up,
                title: AppLocalizations.of(context)!.kpiMonthlyGrowth,
                value: '${viewModel.monthlyGrowth.toStringAsFixed(1)}%',
                color: viewModel.monthlyGrowth >= 0
                    ? colorScheme.tertiary
                    : colorScheme.error,
                subtitle:
                    AppLocalizations.of(context)!.kpiMonthlyGrowthSubtitle,
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
          AppLocalizations.of(context)!.headerPendingManagerRequests,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 400,
          child: PendingManagerTable(
            managers: viewModel.getPendingManagers(),
            onApprove: (id) => _handleApprove(viewModel, id),
            onReject: (id) => _handleReject(viewModel, id),
            onView: _handleViewManager,
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
          AppLocalizations.of(context)!.headerActiveManagers,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 400,
          child: ActiveManagersTable(
            managers: viewModel.getActiveManagers(),
            onView: _handleViewManager,
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
          AppLocalizations.of(context)!.headerRecentActivity,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (auditLogs.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxxl),
              child: Text(AppLocalizations.of(context)!.msgNoRecentActivity),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: auditLogs.length > 10 ? 10 : auditLogs.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              return AuditTimelineItem(auditLog: auditLogs[index]);
            },
          ),
      ],
    );
  }

  Future<void> _handleApprove(
      OwnerDashboardViewModel viewModel, String id) async {
    try {
      await viewModel.approveManager(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.msgManagerApproved)),
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

  Future<void> _handleReject(
      OwnerDashboardViewModel viewModel, String id) async {
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
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.msgManagerRejected)),
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

  Future<void> _handleSuspend(
      OwnerDashboardViewModel viewModel, String id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _SuspendDialog(),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await viewModel.suspendManager(id, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.msgManagerSuspended)),
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

  Future<void> _handleDelete(
      OwnerDashboardViewModel viewModel, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dialogTitleConfirmDelete),
        content: Text(AppLocalizations.of(context)!.dialogDescDeleteManager),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.btnDelete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await viewModel.deleteManager(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.msgManagerDeleted)),
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
      SnackBar(
          content:
              Text(AppLocalizations.of(context)!.msgManagerProfileComingSoon)),
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
      title: Text(AppLocalizations.of(context)!.dialogTitleRejectManager),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dialogLabelReasonRejection,
          hintText: AppLocalizations.of(context)!.dialogHintEnterReason,
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.btnCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(AppLocalizations.of(context)!.dialogActionReject),
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
      title: Text(AppLocalizations.of(context)!.dialogTitleSuspendManager),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.dialogLabelReasonSuspension,
          hintText: AppLocalizations.of(context)!.dialogHintEnterReason,
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.btnCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(AppLocalizations.of(context)!.dialogActionSuspend),
        ),
      ],
    );
  }
}
