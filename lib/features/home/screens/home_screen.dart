import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/cards/stat_card.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/budget_overview_card.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/recent_expenses_card.dart';
import 'package:expense_tracking_desktop_app/features/home/view_models/dashboard_view_model.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';

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
  List<ExpenseWithCategory> recentExpenses = [];
  final _viewModel = DashboardViewModel();

  @override
  void initState() {
    super.initState();
    _loadRecentExpenses();
  }

  Future<void> _loadRecentExpenses() async {
    // Get recent expenses with category info
    final expensesStream = widget.expenseService.watchExpensesWithCategory();
    expensesStream.listen((expenseList) {
      if (mounted) {
        setState(() {
          recentExpenses = expenseList.take(10).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _homeScreen();
  }

  Widget _homeScreen() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Overview of your financial health',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.addExpense),
                  icon: const Icon(Icons.add, size: AppSpacing.iconXs),
                  label: Text(AppStrings.btnAddExpense),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textInverse,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xlMinor,
                        vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Quick Stats Row - Using StreamBuilder for reactive updates
            StreamBuilder<List<CategoryBudgetView>>(
              stream: widget.budgetRepository.watchActiveCategoryBudgets(),
              builder: (context, budgetSnapshot) {
                return StreamBuilder<double>(
                  stream: widget.budgetRepository.watchTotalBudget(),
                  builder: (context, totalBudgetSnapshot) {
                    return StreamBuilder<double>(
                      stream: widget.budgetRepository.watchTotalSpent(),
                      builder: (context, spentSnapshot) {
                        // Calculate stats using ViewModel
                        final stats = _viewModel.calculateStats(
                          activeCategories: budgetSnapshot.data?.length ?? 0,
                          totalBudget: totalBudgetSnapshot.data ?? 0.0,
                          totalExpenses: spentSnapshot.data ?? 0.0,
                        );

                        return LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final isDesktop = width > AppConfig.desktopBreakpoint;
                          final cardWidth =
                              _viewModel.calculateCardWidth(width, isDesktop);

                          return Wrap(
                            spacing: AppSpacing.xlMinor,
                            runSpacing: AppSpacing.xlMinor,
                            children: [
                              StatCard(
                                title: "Total Balance",
                                value:
                                    "${stats.totalBalance.toStringAsFixed(0)} ${AppStrings.currency}",
                                trend: stats.balanceTrend,
                                icon: Icons.account_balance_wallet_outlined,
                                color: stats.balanceColor,
                                width: cardWidth,
                              ),
                              StatCard(
                                title: "Number of Categories",
                                value: "${stats.activeCategories} Active",
                                trend: stats.categoriesTrend,
                                icon: Icons.category_outlined,
                                color: AppColors.purple,
                                width: cardWidth,
                              ),
                              StatCard(
                                title: "Expenses",
                                value:
                                    "${stats.totalExpenses.toStringAsFixed(0)} ${AppStrings.currency}",
                                trend: stats.expenseTrend,
                                icon: Icons.arrow_downward_rounded,
                                color: AppColors.red,
                                width: cardWidth,
                              ),
                              StatCard(
                                title: "Daily Avg Spending",
                                value:
                                    "${stats.dailyAverage.toStringAsFixed(0)} ${AppStrings.currency}",
                                trend: stats.dailyAverageTrend,
                                icon: Icons.trending_down_rounded,
                                color: AppColors.teal,
                                width: cardWidth,
                              ),
                            ],
                          );
                        });
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            Flex(
              direction: screenWidth > 1100 ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: BudgetOverviewCard(
                    budgetRepository: widget.budgetRepository,
                  ),
                ),
                if (screenWidth > 1100) const SizedBox(width: AppSpacing.xl),
                if (screenWidth <= 1100) const SizedBox(height: AppSpacing.xl),
                Expanded(
                  flex: 2,
                  child: RecentExpensesCard(
                    recentExpenses: recentExpenses,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
