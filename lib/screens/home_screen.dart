import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/widgets/sidebar.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';

void main() {
  runApp(const expenseTrackerApp());
}

class expenseTrackerApp extends StatefulWidget {
  const expenseTrackerApp({super.key});

  @override
  State<expenseTrackerApp> createState() => _expenseTrackerAppState();
}

class _expenseTrackerAppState extends State<expenseTrackerApp> {
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

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _quickAction(Icons.add, "Add expense", "Record a new expense quickly", screenWidth, AppColors.primaryBlue, () {
                  setState(() => selectedIndex = 1);
                }),
                _quickAction(Icons.list, "View expenses", "Browse and manage all expenses", screenWidth, AppColors.purple, () {
                  setState(() => selectedIndex = 2);
                }),
                _quickAction(Icons.pie_chart, "Budgets", "Track spending against budgets", screenWidth, AppColors.pink, () {
                  setState(() => selectedIndex = 3);
                }),
                _quickAction(Icons.label, "Categories", "Manage categories and tags", screenWidth, AppColors.teal, () {
                  setState(() => selectedIndex = 4);
                }),
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

 
  Widget _quickAction(IconData icon, String title, String subtitle, double screenWidth, Color color, VoidCallback onTap) {
    double cardWidth = screenWidth * 0.3 - 40; 

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth.clamp(180, 620),
        height: cardWidth.clamp(30, 100),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
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
              Text("\$${spent.toStringAsFixed(2)} / \$${total.toStringAsFixed(0)}", style: AppTextStyles.bodyLarge),
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
          _expenseItem("Printer paper and ink", "Office Supplies", "Oct 20", ["urgent", "office"], 245.50),
          _expenseItem("Flight tickets to conference", "Travel", "Oct 18", ["conference", "business-trip"], 1850.00),
          _expenseItem("Google Ads campaign", "Marketing", "Oct 15", ["online", "advertising"], 3500.00),
        ],
      ),
    );
  }

  Widget _expenseItem(String title, String category, String date, List<String> tags, double amount) {
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
        TextButton(onPressed: () {}, child: Text(actionText)),
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
          BoxShadow(color: AppColors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      );
}
