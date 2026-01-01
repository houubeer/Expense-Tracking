import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracking_desktop_app/features/home/providers/dashboard_provider.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';

void main() {
  group('DashboardState', () {
    group('Reimbursable data', () {
      test('stores reimbursable total and count', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 0,
          totalExpenses: 0,
          totalBalance: 0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
          reimbursableTotal: 500.0,
          reimbursableCount: 5,
        );

        expect(state.reimbursableTotal, equals(500.0));
        expect(state.reimbursableCount, equals(5));
      });

      test('has default zero values for reimbursable data', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 0,
          totalExpenses: 0,
          totalBalance: 0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.reimbursableTotal, equals(0.0));
        expect(state.reimbursableCount, equals(0));
      });
    });

    group('Balance Trend', () {
      test('calculates positive balance as percentage', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 1000.0,
          totalExpenses: 800.0,
          totalBalance: 200.0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.balanceTrend, equals('+20.0%'));
      });

      test('calculates negative balance as percentage', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 1000.0,
          totalExpenses: 1200.0,
          totalBalance: -200.0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.balanceTrend, equals('-20.0%'));
      });

      test('handles zero budget gracefully', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 0,
          totalExpenses: 100.0,
          totalBalance: -100.0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.balanceTrend, equals('+0.0%'));
      });
    });

    group('Expense Trend', () {
      test('calculates expense as percentage of budget', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 1000.0,
          totalExpenses: 300.0,
          totalBalance: 0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.expenseTrend, equals('-30.0%'));
      });

      test('handles zero budget gracefully', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 0,
          totalExpenses: 100.0,
          totalBalance: 0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.expenseTrend, equals('-0.0%'));
      });
    });

    group('Daily Average Trend', () {
      test('calculates daily average as percentage of daily budget', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 3000.0, // 100/day
          totalExpenses: 0,
          totalBalance: 0,
          dailyAverage: 80.0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.dailyAverageTrend, equals('-80.0%'));
      });

      test('handles zero budget gracefully', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 0,
          totalExpenses: 0,
          totalBalance: 0,
          dailyAverage: 50.0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.dailyAverageTrend, equals('-0.0%'));
      });
    });

    group('Categories Trend', () {
      test('shows count of active categories', () {
        const state = DashboardState(
          activeCategories: 5,
          totalBudget: 0,
          totalExpenses: 0,
          totalBalance: 0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.categoriesTrend, equals('+5'));
      });

      test('shows zero when no categories', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 0,
          totalExpenses: 0,
          totalBalance: 0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.categoriesTrend, equals('0'));
      });
    });

    group('Loading State', () {
      test('creates loading state with zero values', () {
        final state = DashboardState.loading();

        expect(state.activeCategories, equals(0));
        expect(state.totalBudget, equals(0));
        expect(state.totalExpenses, equals(0));
        expect(state.totalBalance, equals(0));
        expect(state.dailyAverage, equals(0));
        expect(state.recentExpenses, isEmpty);
        expect(state.budgetData, isEmpty);
        expect(state.reimbursableTotal, equals(0));
        expect(state.reimbursableCount, equals(0));
      });
    });

    group('fromData factory', () {
      test('creates state from data with calculations', () {
        const budgets = <CategoryBudgetView>[];
        final expenses = <ExpenseWithCategory>[];

        final state = DashboardState.fromData(
          budgets: budgets,
          totalBudget: 5000.0,
          totalExpenses: 2000.0,
          expenses: expenses,
          reimbursableTotal: 500.0,
          reimbursableCount: 3,
        );

        expect(state.totalBudget, equals(5000.0));
        expect(state.totalExpenses, equals(2000.0));
        expect(state.totalBalance, equals(3000.0));
        expect(state.reimbursableTotal, equals(500.0));
        expect(state.reimbursableCount, equals(3));
      });

      test('calculates daily average correctly', () {
        final state = DashboardState.fromData(
          budgets: [],
          totalBudget: 3000.0,
          totalExpenses: 1000.0,
          expenses: [],
        );

        // Daily average = 1000 / 30
        expect(state.dailyAverage, closeTo(33.33, 0.1));
      });

      test('limits recent expenses to 10', () {
        final expenses = List.generate(
          15,
          (i) => ExpenseWithCategory(
            expense: Expense(
              id: i,
              amount: 100.0,
              date: DateTime.now(),
              description: 'Expense $i',
              categoryId: 1,
              createdAt: DateTime.now(),
              isReimbursable: false,
              version: 1,
              isSynced: false,
            ),
            category: Category(
              id: 1,
              name: 'Test',
              color: 0xFF000000,
              iconCodePoint: '0xe6db',
              budget: 1000.0,
              spent: 0.0,
              version: 1,
              createdAt: DateTime.now(),
              isSynced: false,
            ),
          ),
        );

        final state = DashboardState.fromData(
          budgets: [],
          totalBudget: 0,
          totalExpenses: 0,
          expenses: expenses,
        );

        expect(state.recentExpenses.length, equals(10));
      });
    });

    group('Color Properties', () {
      test('balance color is indigo for positive balance', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 1000.0,
          totalExpenses: 500.0,
          totalBalance: 500.0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.balanceColor.value, equals(const Color(0xFF6366F1).value));
      });

      test('balance color is red for negative balance', () {
        const state = DashboardState(
          activeCategories: 0,
          totalBudget: 500.0,
          totalExpenses: 1000.0,
          totalBalance: -500.0,
          dailyAverage: 0,
          recentExpenses: [],
          budgetData: [],
        );

        expect(state.balanceColor.value, equals(const Color(0xFFEF4444).value));
      });
    });
  });
}
