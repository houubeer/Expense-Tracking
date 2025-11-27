import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/daos/expense_dao.dart';
import 'package:expense_tracking_desktop_app/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/main.dart' as main_app;
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppDatabase database;
  late BudgetRepository budgetRepository;
  List<ExpenseWithCategory> recentExpenses = [];

  @override
  void initState() {
    super.initState();
    database = main_app.database;
    budgetRepository = BudgetRepository(database);
    _loadRecentExpenses();
  }

  Future<void> _loadRecentExpenses() async {
    // Get recent expenses with category info
    final expensesStream = database.expenseDao.watchExpensesWithCategory();
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
      padding: const EdgeInsets.all(40.0),
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
                  onPressed: () => widget.onNavigate(1),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Expense"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTextStyles.button,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

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
                          final isDesktop = width > 1000;
                          final cardWidth =
                              isDesktop ? (width - 60) / 4 : (width - 20) / 2;

                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _statCard(
                                  "Total Balance",
                                  "${totalBalance.toStringAsFixed(0)} DZD",
                                  totalBalance >= 0
                                      ? "+${((totalBalance / totalBudget) * 100).toStringAsFixed(1)}%"
                                      : "-${((totalBalance.abs() / totalBudget) * 100).toStringAsFixed(1)}%",
                                  Icons.account_balance_wallet_outlined,
                                  totalBalance >= 0
                                      ? AppColors.accent
                                      : AppColors.red,
                                  cardWidth),
                              _statCard(
                                  "Number of Categories",
                                  "$activeCategories Active",
                                  activeCategories > 0
                                      ? "+$activeCategories"
                                      : "0",
                                  Icons.category_outlined,
                                  AppColors.purple,
                                  cardWidth),
                              _statCard(
                                  "Expenses",
                                  "${totalExpenses.toStringAsFixed(0)} DZD",
                                  "-${((totalExpenses / totalBudget) * 100).toStringAsFixed(1)}%",
                                  Icons.arrow_downward_rounded,
                                  AppColors.red,
                                  cardWidth),
                              _statCard(
                                  "Daily Avg Spending",
                                  "${dailyAverage.toStringAsFixed(0)} DZD",
                                  "-${((dailyAverage / (totalBudget / 30)) * 100).toStringAsFixed(1)}%",
                                  Icons.trending_down_rounded,
                                  AppColors.teal,
                                  cardWidth),
                            ],
                          );
                        });
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            Flex(
              direction: screenWidth > 1100 ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _budgetOverviewCard(),
                ),
                if (screenWidth > 1100) const SizedBox(width: 24),
                if (screenWidth <= 1100) const SizedBox(height: 24),
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

  Widget _statCard(String title, String value, String trend, IconData icon,
      Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trend.startsWith('+')
                      ? AppColors.green.withValues(alpha: 0.1)
                      : AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: AppTextStyles.caption.copyWith(
                    color:
                        trend.startsWith('+') ? AppColors.green : AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _budgetOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Budget Overview", "Manage Budgets"),
          const SizedBox(height: 24),
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
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                        "No budgets set yet. Go to Budgets to create one."),
                  ),
                );
              }

              // Filter only categories with budgets
              final activeBudgets =
                  budgetData.where((b) => !b.hasNoBudget).toList();

              if (activeBudgets.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                        "No budgets set yet. Go to Budgets to create one."),
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
                              'No expenses yet',
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
                  const SizedBox(width: 32),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
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
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
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
          padding: const EdgeInsets.only(left: 24, top: 8),
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
                    const SizedBox(width: 8),
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
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Recent Expenses", "View All"),
          const SizedBox(height: 16),
          // Scrollable expenses list
          SizedBox(
            height: 300,
            child: recentExpenses.isEmpty
                ? const Center(child: Text("No expenses yet"))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < recentExpenses.length; i++) ...[
                          _expenseItem(
                            _truncateDescription(
                                recentExpenses[i].expense.description),
                            recentExpenses[i].category.name,
                            _formatDate(recentExpenses[i].expense.date),
                            recentExpenses[i].expense.amount,
                            Color(recentExpenses[i].category.color),
                          ),
                          if (i < recentExpenses.length - 1)
                            const Divider(height: 24, color: AppColors.border),
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

  Widget _expenseItem(String title, String category, String date, double amount,
      Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long_rounded, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyles.bodyLarge
                      .copyWith(fontWeight: FontWeight.w600)),
              Text("$category • $date", style: AppTextStyles.caption),
            ],
          ),
        ),
        Text(
          "-${amount.toStringAsFixed(2)}",
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _cardHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        TextButton(
          onPressed: () {
            if (title.contains("Budget")) {
              widget.onNavigate(3);
            } else if (title.contains("Expenses")) {
              widget.onNavigate(2);
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: AppTextStyles.label,
          ),
          child: Text(actionText),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
}
