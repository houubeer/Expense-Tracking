import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/dashboard_header.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/dashboard_stats_grid.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/budget_overview_card.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/recent_expenses_card.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/reimbursable_summary_card.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            const SizedBox(height: AppSpacing.xxl),
            dashboardState.when(
              data: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardStatsGrid(state: state),
                  const SizedBox(height: AppSpacing.xxl),
                  // Reimbursable summary row (show if there are reimbursable expenses)
                  if (state.reimbursableTotal > 0) ...[
                    ReimbursableSummaryCard(
                      totalAmount: state.reimbursableTotal,
                      expenseCount: state.reimbursableCount,
                      onTap: () => context.go(AppRoutes.viewExpenses),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                  Flex(
                    direction:
                        screenWidth > 1100 ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (screenWidth > 1100)
                        Expanded(
                          flex: 3,
                          child: BudgetOverviewCard(
                            budgetData: state.budgetData,
                            itemsToShow: screenWidth > 1400 ? 8 : 5,
                          ),
                        )
                      else
                        BudgetOverviewCard(
                          budgetData: state.budgetData,
                          itemsToShow: 5,
                        ),
                      if (screenWidth > 1100)
                        const SizedBox(width: AppSpacing.xl),
                      if (screenWidth <= 1100)
                        const SizedBox(height: AppSpacing.xl),
                      if (screenWidth > 1100)
                        Expanded(
                          flex: 2,
                          child: RecentExpensesCard(
                            recentExpenses: state.recentExpenses,
                          ),
                        )
                      else
                        RecentExpensesCard(
                          recentExpenses: state.recentExpenses,
                        ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
