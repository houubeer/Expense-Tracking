import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/widgets/sidebar.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

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
    const Center(child: Text("Budgets Screen")),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader("Budget Overview", "Manage"),
          const SizedBox(height: 10),
          _budgetItem("Office Supplies", 245.50, 5000, AppColors.primaryBlue),
          _budgetItem("Travel", 1850.00, 10000, AppColors.purple),
          _budgetItem("Marketing", 3500.00, 15000, AppColors.pink),
          _budgetItem("Software & Tools", 0.0, 8000, AppColors.teal),
          _budgetItem("Utilities", 0.0, 3000, AppColors.orange),
        ],
      ),
    );
  }

  Widget _budgetItem(String title, double spent, double total, Color color) {
    final progress = spent / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.circle, size: 10, color: color),
                const SizedBox(width: 6),
                Text(title, style: AppTextStyles.bodyLarge),
              ]),
              Text(
                  "\$${spent.toStringAsFixed(2)} / \$${total.toStringAsFixed(0)}",
                  style: AppTextStyles.bodyLarge),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: AppColors.grey300,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
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
          Text("\$${amount.toStringAsFixed(2)}", style: AppTextStyles.heading3),
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
