import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/screens/home/home_screen.dart';
import 'package:expense_tracking_desktop_app/screens/expenses/add_expense_screen.dart';
import 'package:expense_tracking_desktop_app/screens/expenses/expenses_list_screen.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/widgets/common/sidebar.dart';
import 'package:expense_tracking_desktop_app/screens/budget/budget_setting_screen.dart';
import 'package:expense_tracking_desktop_app/main.dart' as main_app;

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  int selectedIndex = 0;
  int? selectedCategoryId;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onNavigate: (index) => setState(() {
            selectedIndex = index;
            selectedCategoryId = null;
          }),
        );
      case 1:
        return AddExpenseScreen(
          database: main_app.database,
          onNavigate: (index) => setState(() {
            selectedIndex = index;
            selectedCategoryId = null;
          }),
          preSelectedCategoryId: selectedCategoryId,
        );
      case 2:
        return ExpensesListScreen(
          database: main_app.database,
          onNavigate: (index, {int? categoryId}) => setState(() {
            selectedIndex = index;
            selectedCategoryId = categoryId;
          }),
        );
      case 3:
        return BudgetSettingScreen(
          database: main_app.database,
          onNavigate: (index, {int? categoryId}) => setState(() {
            selectedIndex = index;
            selectedCategoryId = categoryId;
          }),
        );
      default:
        return const Center(child: Text("Unknown Screen"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ExpenseTracker',
      theme: ThemeData(
        fontFamily: 'Raleway',
        scaffoldBackgroundColor: AppColors.background,
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
                  child: _getScreen(selectedIndex),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
