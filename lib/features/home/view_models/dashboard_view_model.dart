import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_dashboard_budget_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:rxdart/rxdart.dart';

class DashboardViewModel extends ChangeNotifier {

  DashboardViewModel(this._budgetReader, this._expenseService);
  final IDashboardBudgetReader _budgetReader;
  final IExpenseService _expenseService;

  /// Combines all streams into a single DashboardState stream
  /// This flattens the nested StreamBuilders into one clean stream
  Stream<DashboardState> watchDashboardState() {
    // Ensure each source stream emits an initial value so combineLatest
    // can produce an initial DashboardState immediately instead of
    // waiting for all streams to emit (which can cause the UI to show
    // an indefinite loading state if one source is delayed).
    final budgets$ = _budgetReader.watchActiveCategoryBudgets().startWith(<CategoryBudgetView>[]);
    final totalBudget$ = _budgetReader.watchTotalBudget().startWith(0.0);
    final totalExpenses$ = _budgetReader.watchTotalSpent().startWith(0.0);
    final expenses$ = _expenseService.watchExpensesWithCategory().startWith(<ExpenseWithCategory>[]);

    return Rx.combineLatest4<List<CategoryBudgetView>, double, double, List<ExpenseWithCategory>, DashboardState>(
      budgets$,
      totalBudget$,
      totalExpenses$,
      expenses$,
      (
        List<CategoryBudgetView> budgets,
        double totalBudget,
        double totalExpenses,
        List<ExpenseWithCategory> expenses,
      ) {
        // Calculate reimbursable totals from expenses
        final reimbursableExpenses = expenses
            .where((e) => e.expense.isReimbursable)
            .toList();
        final reimbursableTotal = reimbursableExpenses.fold<double>(
          0.0,
          (sum, e) => sum + e.expense.amount,
        );

        // All calculations happen here, UI just displays
        return DashboardState.fromData(
          budgets: budgets,
          totalBudget: totalBudget,
          totalExpenses: totalExpenses,
          expenses: expenses,
          reimbursableTotal: reimbursableTotal,
          reimbursableCount: reimbursableExpenses.length,
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
}
