import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/widgets/sidebar.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/ui/screens/budget_setting_screen.dart';
import 'package:expense_tracking_desktop_app/main.dart' as main_app;
import 'package:fl_chart/fl_chart.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  int selectedIndex = 0;

  late final List<Widget> screens = [
    Container(), // Dashboard placeholder (will be built dynamically)
    const Center(child: Text("Add Expense")),
    const Center(child: Text("View expenses Screen")),
    BudgetSettingScreen(
      database: main_app.database,
      onNavigate: (index) => setState(() => selectedIndex = index),
    ), // Budget Screen
    const Center(child: Text("Categories Screen")),
    const Center(child: Text("Settings Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpenseTracker',
      theme: ThemeData(
        fontFamily: 'Raleway',
        scaffoldBackgroundColor: AppColors.grey200,
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => selectedIndex = index);
                  },
                ),
                Expanded(
                  child: selectedIndex == 0
                      ? _homeScreen()
                      : screens[selectedIndex],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _homeScreen() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to ExpenseTracker',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your expense, track budgets, and stay on top of your finances.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),

            // Quick Actions Block - 2x2 Grid matching cards below
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: [
                if (screenWidth > 900) ...{
                  // Desktop: 2x2 grid matching the cards below
                  SizedBox(
                    width: (screenWidth -
                            64 -
                            20 -
                            (MediaQuery.of(context).size.width * 0.2)) /
                        2,
                    child: _quickAction(
                        Icons.add,
                        "Add expense",
                        "Record a new expense quickly",
                        AppColors.primaryBlue, () {
                      setState(() => selectedIndex = 1);
                    }),
                  ),
                  SizedBox(
                    width: (screenWidth -
                            64 -
                            20 -
                            (MediaQuery.of(context).size.width * 0.2)) /
                        2,
                    child: _quickAction(Icons.list, "View expenses",
                        "Browse and manage all expenses", AppColors.purple, () {
                      setState(() => selectedIndex = 2);
                    }),
                  ),
                  SizedBox(
                    width: (screenWidth -
                            64 -
                            20 -
                            (MediaQuery.of(context).size.width * 0.2)) /
                        2,
                    child: _quickAction(Icons.pie_chart, "Budgets",
                        "Track spending against budgets", AppColors.pink, () {
                      setState(() => selectedIndex = 3);
                    }),
                  ),
                  SizedBox(
                    width: (screenWidth -
                            64 -
                            20 -
                            (MediaQuery.of(context).size.width * 0.2)) /
                        2,
                    child: _quickAction(Icons.label, "Categories",
                        "Manage categories and tags", AppColors.teal, () {
                      setState(() => selectedIndex = 4);
                    }),
                  ),
                } else ...{
                  // Mobile: Full width cards
                  _quickAction(
                      Icons.add,
                      "Add expense",
                      "Record a new expense quickly",
                      AppColors.primaryBlue, () {
                    setState(() => selectedIndex = 1);
                  }),
                  _quickAction(Icons.list, "View expenses",
                      "Browse and manage all expenses", AppColors.purple, () {
                    setState(() => selectedIndex = 2);
                  }),
                  _quickAction(Icons.pie_chart, "Budgets",
                      "Track spending against budgets", AppColors.pink, () {
                    setState(() => selectedIndex = 3);
                  }),
                  _quickAction(Icons.label, "Categories",
                      "Manage categories and tags", AppColors.teal, () {
                    setState(() => selectedIndex = 4);
                  }),
                },
              ],
            ),

            const SizedBox(height: 32),

            Flex(
              direction: screenWidth > 900 ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _budgetOverviewCard()),
                if (screenWidth > 900) const SizedBox(width: 20),
                Expanded(child: _recentexpensesCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return _QuickActionCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
    );
  }

  Widget _budgetOverviewCard() {
    // Budget data
    final budgetData = [
      {
        'name': 'Office Supplies',
        'spent': 245.50,
        'total': 5000.0,
        'color': AppColors.primaryBlue
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
        'name': 'Software & Tools',
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
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Budget Overview", "Manage"),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 45,
                        sections: budgetData.map((data) {
                          final spent = data['spent'] as double;
                          final total = data['total'] as double;
                          final color = data['color'] as Color;
                          final percentage =
                              total > 0 ? (spent / total * 100) : 0.0;

                          return PieChartSectionData(
                            color: color,
                            value: spent > 0
                                ? spent
                                : (total * 0.01), // Show slice even if 0
                            title: spent > 0
                                ? '${percentage.toStringAsFixed(0)}%'
                                : '',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legend
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: budgetData.map((data) {
                        final name = data['name'] as String;
                        final spent = data['spent'] as double;
                        final total = data['total'] as double;
                        final color = data['color'] as Color;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${spent.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} DZD',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.grey,
                                        fontSize: 11,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentexpensesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Recent expenses", "View All"),
          const SizedBox(height: 10),
          _expenseItem("Printer paper and ink", "Office Supplies", "Oct 20",
              ["urgent", "office"], 245.50),
          _expenseItem("Flight tickets to conference", "Travel", "Oct 18",
              ["conference", "business-trip"], 1850.00),
          _expenseItem("Google Ads campaign", "Marketing", "Oct 15",
              ["online", "advertising"], 3500.00),
        ],
      ),
    );
  }

  Widget _expenseItem(String title, String category, String date,
      List<String> tags, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _tag(category, AppColors.grey300),
                    _tag(date, AppColors.grey200),
                    ...tags.map((t) => _tag(t, AppColors.grey200)),
                  ],
                ),
              ],
            ),
          ),
          Text("${amount.toStringAsFixed(2)} DZD",
              style: AppTextStyles.heading3),
        ],
      ),
    );
  }

  Widget _cardHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.heading3),
        TextButton(
          onPressed: () {
            // Navigate based on the card type
            if (title == "Budget Overview") {
              setState(() => selectedIndex = 3); // Budgets page
            } else if (title == "Recent expenses") {
              setState(() => selectedIndex = 2); // View expenses page
            }
          },
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.caption),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2)),
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
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    AppColors.black.withValues(alpha: _isHovered ? 0.18 : 0.12),
                blurRadius: _isHovered ? 10 : 6,
                offset: Offset(0, _isHovered ? 4 : 2),
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
                  color: widget.color.withValues(alpha: _isHovered ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: _isHovered ? 30 : 28,
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
                            _isHovered ? FontWeight.w600 : FontWeight.normal,
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
