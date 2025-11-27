import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    backgroundColor: AppColors.accent,
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

            // Quick Stats Row
            LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isDesktop = width > 1000;
              final cardWidth = isDesktop
                  ? (width - 60) / 4
                  : (width - 20) / 2; // 4 cards on desktop, 2 on tablet

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _statCard(
                      "Total Balance",
                      "245,500 DZD",
                      "+2.5%",
                      Icons.account_balance_wallet_outlined,
                      AppColors.accent,
                      cardWidth),
                  _statCard("Income", "520,000 DZD", "+12%",
                      Icons.arrow_upward_rounded, AppColors.green, cardWidth),
                  _statCard("Expenses", "124,000 DZD", "-5%",
                      Icons.arrow_downward_rounded, AppColors.red, cardWidth),
                  _statCard("Savings", "121,500 DZD", "+8%",
                      Icons.account_balance_rounded, AppColors.purple, cardWidth),
                ],
              );
            }),

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
                  child: _recentexpensesCard(),
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
                    color: trend.startsWith('+')
                        ? AppColors.green
                        : AppColors.red,
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
    // Budget data
    final budgetData = [
      {
        'name': 'Office Supplies',
        'spent': 245.50,
        'total': 5000.0,
        'color': AppColors.accent
      },
      {
        'name': 'Travel',
        'spent': 500.00,
        'total': 10000.0,
        'color': AppColors.purple
      },
      {
        'name': 'Marketing',
        'spent': 500.00,
        'total': 15000.0,
        'color': AppColors.pink
      },
      {
        'name': 'Software',
        'spent': 700.0,
        'total': 8000.0,
        'color': AppColors.teal
      },
      {
        'name': 'Utilities',
        'spent': 250.0,
        'total': 3000.0,
        'color': AppColors.orange
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Budget Overview", "Manage Budgets"),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pie Chart
              SizedBox(
                height: 200,
                width: 200,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    sections: budgetData.map((data) {
                      final spent = data['spent'] as double;
                      final total = data['total'] as double;
                      final color = data['color'] as Color;


                      return PieChartSectionData(
                        color: color,
                        value: spent > 0 ? spent : (total * 0.01),
                        title: '',
                        radius: 20,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              // Legend
              Expanded(
                child: Column(
                  children: budgetData.map((data) {
                    final name = data['name'] as String;
                    final spent = data['spent'] as double;
                    final total = data['total'] as double;
                    final color = data['color'] as Color;
                    final percentage =
                        total > 0 ? (spent / total * 100) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(name,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary)),
                                    Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: AppColors.surfaceAlt,
                                    color: color,
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentexpensesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Recent Transactions", "View All"),
          const SizedBox(height: 16),
          _expenseItem("Printer paper and ink", "Office Supplies", "Oct 20",
              245.50, AppColors.accent),
          const Divider(height: 24, color: AppColors.border),
          _expenseItem("Flight tickets", "Travel", "Oct 18", 1850.00,
              AppColors.purple),
          const Divider(height: 24, color: AppColors.border),
          _expenseItem("Google Ads", "Marketing", "Oct 15", 3500.00,
              AppColors.pink),
          const Divider(height: 24, color: AppColors.border),
          _expenseItem("Slack Subscription", "Software", "Oct 12", 120.00,
              AppColors.teal),
        ],
      ),
    );
  }

  Widget _expenseItem(String title, String category, String date,
      double amount, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long_rounded,
              color: iconColor, size: 20),
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
            } else if (title.contains("Recent")) {
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

// Quick Action Card with Hover Effect
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 12 : 8,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          transform: _isHovered
              ? Matrix4.translationValues(0, -4, 0)
              : Matrix4.identity(),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: _isHovered ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight:
                            _isHovered ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
