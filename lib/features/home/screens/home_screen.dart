import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/app_config.dart';
import 'package:expense_tracking_desktop_app/constants/strings.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/cards/stat_card.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/section_header.dart';
import 'package:expense_tracking_desktop_app/features/home/widgets/expense_list_item.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase database;

  const HomeScreen({super.key, required this.database});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BudgetRepository budgetRepository;
  List<ExpenseWithCategory> recentExpenses = [];

  @override
  void initState() {
    super.initState();
    budgetRepository = BudgetRepository(widget.database);
    _loadRecentExpenses();
  }

  Future<void> _loadRecentExpenses() async {
    // Get recent expenses with category info
    final expensesStream =
        widget.database.expenseDao.watchExpensesWithCategory();
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
                        horizontal: AppSpacing.xl - 4, vertical: AppSpacing.lg),
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
              stream: budgetRepository.watchActiveCategoryBudgets(),
              builder: (context, budgetSnapshot) {
                return StreamBuilder<double>(
                  stream: budgetRepository.watchTotalBudget(),
                  builder: (context, totalBudgetSnapshot) {
                    return StreamBuilder<double>(
                      stream: budgetRepository.watchTotalSpent(),
                      builder: (context, spentSnapshot) {
                        final activeCategories =
                            budgetSnapshot.data?.length ?? 0;
                        final totalBudget = totalBudgetSnapshot.data ?? 0.0;
                        final totalExpenses = spentSnapshot.data ?? 0.0;
                        final totalBalance = totalBudget - totalExpenses;
                        final dailyAverage = totalExpenses / 30;

                        return LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final isDesktop = width > AppConfig.desktopBreakpoint;
                          final cardWidth =
                              isDesktop ? (width - 60) / 4 : (width - AppSpacing.xl + 4) / 2;

                          return Wrap(
                            spacing: AppSpacing.xl - 4,
                            runSpacing: AppSpacing.xl - 4,
                            children: [
                              StatCard(
                                title: "Total Balance",
                                value: "${totalBalance.toStringAsFixed(0)} DZD",
                                trend: totalBalance >= 0
                                    ? "+${((totalBalance / totalBudget) * 100).toStringAsFixed(1)}%"
                                    : "-${((totalBalance.abs() / totalBudget) * 100).toStringAsFixed(1)}%",
                                icon: Icons.account_balance_wallet_outlined,
                                color: totalBalance >= 0
                                    ? AppColors.accent
                                    : AppColors.red,
                                width: cardWidth,
                              ),
                              StatCard(
                                title: "Number of Categories",
                                value: "$activeCategories Active",
                                trend: activeCategories > 0
                                    ? "+$activeCategories"
                                    : "0",
                                icon: Icons.category_outlined,
                                color: AppColors.purple,
                                width: cardWidth,
                              ),
                              StatCard(
                                title: "Expenses",
                                value:
                                    "${totalExpenses.toStringAsFixed(0)} DZD",
                                trend:
                                    "-${((totalExpenses / totalBudget) * 100).toStringAsFixed(1)}%",
                                icon: Icons.arrow_downward_rounded,
                                color: AppColors.red,
                                width: cardWidth,
                              ),
                              StatCard(
                                title: "Daily Avg Spending",
                                value: "${dailyAverage.toStringAsFixed(0)} DZD",
                                trend:
                                    "-${((dailyAverage / (totalBudget / 30)) * 100).toStringAsFixed(1)}%",
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
                  child: _budgetOverviewCard(),
                ),
                if (screenWidth > 1100) const SizedBox(width: AppSpacing.xl),
                if (screenWidth <= 1100) const SizedBox(height: AppSpacing.xl),
                Expanded(
                  flex: 2,
                  child: _recentExpensesCard(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppStrings.titleBudgetOverview,
            actionText: AppStrings.navManageBudgets,
            onActionPressed: () => context.go(AppRoutes.budgets),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Use StreamBuilder for reactive budget updates
          StreamBuilder<List<CategoryBudgetView>>(
            stream: budgetRepository.watchCategoryBudgetsSortedBySpending(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final budgetData = snapshot.data ?? [];

              if (budgetData.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Text(AppStrings.msgNoBudgetsYet),
                  ),
                );
              }

              // Filter only categories with budgets
              final activeBudgets =
                  budgetData.where((b) => !b.hasNoBudget).toList();

              if (activeBudgets.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Text(AppStrings.msgNoBudgetsYet),
                  ),
                );
              }

              // Take top 5 and group others
              final top5Budgets = activeBudgets.take(5).toList();
              final otherBudgets = activeBudgets.skip(5).toList();

              // Prepare pie chart data - only categories with expenses
              final pieChartData =
                  top5Budgets.where((b) => b.totalSpent > 0).toList();

              // Calculate "Others" total - only if they have expenses
              double othersSpent = 0;
              double othersTotal = 0;
              for (var budget in otherBudgets) {
                if (budget.totalSpent > 0) {
                  othersSpent += budget.totalSpent;
                }
                othersTotal += budget.category.budget;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pie Chart - Expenses Only
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: pieChartData.isEmpty && othersSpent == 0
                        ? Center(
                            child: Text(
                              AppStrings.msgNoExpensesYet,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 75,
                              sections: [
                                ...pieChartData.map((budgetView) {
                                  return PieChartSectionData(
                                    color: Color(budgetView.category.color),
                                    value: budgetView.totalSpent,
                                    title: '',
                                    radius: 22,
                                  );
                                }),
                                if (othersSpent > 0)
                                  PieChartSectionData(
                                    color: AppColors.textTertiary,
                                    value: othersSpent,
                                    title: '',
                                    radius: 22,
                                  ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  // Scrollable Legend
                  Expanded(
                    child: SizedBox(
                      height: 220,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Top 5 budgets
                            ...top5Budgets.map((budgetView) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _budgetLegendItem(budgetView),
                              );
                            }),
                            // Others section
                            if (otherBudgets.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _othersLegendItem(
                                  otherBudgets,
                                  othersSpent,
                                  othersTotal,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _budgetLegendItem(CategoryBudgetView budgetView) {
    final color = Color(budgetView.category.color);

    return Row(
      children: [
        Container(
          width: AppSpacing.md,
          height: AppSpacing.md,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: AppConfig.shadowBlurRadiusSm,
                offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budgetView.category.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${budgetView.percentageUsed.toStringAsFixed(1)}%',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                child: LinearProgressIndicator(
                  value: budgetView.percentageUsed / 100,
                  backgroundColor: AppColors.surfaceAlt,
                  color: color,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${budgetView.totalSpent.toStringAsFixed(0)} / ${budgetView.category.budget.toStringAsFixed(0)} DZD',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _othersLegendItem(
    List<CategoryBudgetView> otherBudgets,
    double othersSpent,
    double othersTotal,
  ) {
    final percentage =
        othersTotal > 0 ? (othersSpent / othersTotal * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: AppSpacing.md,
              height: AppSpacing.md,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Others (${otherBudgets.length})',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.surfaceAlt,
                      color: AppColors.textTertiary,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${othersSpent.toStringAsFixed(0)} / ${othersTotal.toStringAsFixed(0)} DZD',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Show breakdown
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl, top: AppSpacing.sm),
          child: Column(
            children: otherBudgets.map((budget) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Color(budget.category.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        budget.category.name,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      '${budget.percentageUsed.toStringAsFixed(0)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _recentExpensesCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: AppStrings.titleRecentExpenses,
            actionText: AppStrings.navViewAll,
            onActionPressed: () => context.go(AppRoutes.viewExpenses),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Scrollable expenses list
          SizedBox(
            height: 300,
            child: recentExpenses.isEmpty
                ? Center(child: Text(AppStrings.msgNoExpensesYet))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < recentExpenses.length; i++) ...[
                          ExpenseListItem(
                            title: _truncateDescription(
                                recentExpenses[i].expense.description),
                            category: recentExpenses[i].category.name,
                            date: _formatDate(recentExpenses[i].expense.date),
                            amount: recentExpenses[i].expense.amount,
                            iconColor: Color(recentExpenses[i].category.color),
                          ),
                          if (i < recentExpenses.length - 1)
                            const Divider(height: AppSpacing.xl, color: AppColors.border),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _truncateDescription(String description, {int maxWords = 4}) {
    final words = description.split(' ');
    if (words.length <= maxWords) {
      return description;
    }
    return '${words.take(maxWords).join(' ')}...';
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: AppConfig.shadowBlurRadiusMd,
            offset: Offset(AppConfig.shadowOffsetX, AppConfig.shadowOffsetY),
          ),
        ],
      );
}
