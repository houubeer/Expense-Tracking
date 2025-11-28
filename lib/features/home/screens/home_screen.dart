import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/dashboard_header.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/dashboard_stats_grid.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/budget_overview_card.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/recent_expenses_card.dart';
import 'package:expense_tracking_desktop_app/features/home/view_models/dashboard_view_model.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';

class HomeScreen extends StatefulWidget {
  final BudgetRepository budgetRepository;
  final ExpenseService expenseService;

  const HomeScreen({
    super.key,
    required this.budgetRepository,
    required this.expenseService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      widget.budgetRepository,
      widget.expenseService,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            const SizedBox(height: AppSpacing.xxl),
            StreamBuilder<DashboardState>(
              stream: _viewModel.watchDashboardState(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final state = snapshot.data ?? DashboardState.loading();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardStatsGrid(state: state),
                    const SizedBox(height: AppSpacing.xxl),
                    Flex(
                      direction: screenWidth > 1100
                          ? Axis.horizontal
                          : Axis.vertical,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: BudgetOverviewCard(
                            budgetRepository: widget.budgetRepository,
                          ),
                        ),
                        if (screenWidth > 1100)
                          const SizedBox(width: AppSpacing.xl),
                        if (screenWidth <= 1100)
                          const SizedBox(height: AppSpacing.xl),
                        Expanded(
                          flex: 2,
                          child: RecentExpensesCard(
                            recentExpenses: state.recentExpenses,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
