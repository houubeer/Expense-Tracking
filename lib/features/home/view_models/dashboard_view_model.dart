import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:rxdart/rxdart.dart';

class DashboardViewModel extends ChangeNotifier {
  final IBudgetRepository _budgetRepository;
  final IExpenseService _expenseService;

  DashboardViewModel(this._budgetRepository, this._expenseService);

  /// Combines all streams into a single DashboardState stream
  /// This flattens the nested StreamBuilders into one clean stream
  Stream<DashboardState> watchDashboardState() {
    return Rx.combineLatest4(
      _budgetRepository.watchActiveCategoryBudgets(),
      _budgetRepository.watchTotalBudget(),
      _budgetRepository.watchTotalSpent(),
      _expenseService.watchExpensesWithCategory(),
      (
        List<CategoryBudgetView> budgets,
        double totalBudget,
        double totalExpenses,
        List<ExpenseWithCategory> expenses,
      ) {
        // All calculations happen here, UI just displays
        return DashboardState.fromData(
          budgets: budgets,
          totalBudget: totalBudget,
          totalExpenses: totalExpenses,
          expenses: expenses,
        );
      },
    );
  }

  /// Calculate dashboard statistics from raw data (legacy)
  DashboardState calculateStats({
    required int activeCategories,
    required double totalBudget,
    required double totalExpenses,
  }) {
    final totalBalance = totalBudget - totalExpenses;
    final dailyAverage = totalExpenses / 30;

    return DashboardState(
      activeCategories: activeCategories,
      totalBudget: totalBudget,
      totalExpenses: totalExpenses,
      totalBalance: totalBalance,
      dailyAverage: dailyAverage,
      recentExpenses: const [],
      budgetData: const [],
    );
  }

  /// Calculate card width based on screen constraints
  double calculateCardWidth(double screenWidth, bool isDesktop) {
    return isDesktop ? (screenWidth - 60) / 4 : (screenWidth - 20) / 2;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
