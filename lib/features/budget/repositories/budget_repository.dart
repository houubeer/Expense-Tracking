import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/models/category_budget_view.dart';
import 'package:rxdart/rxdart.dart';

/// Repository that combines category and expense data to provide
/// a reactive stream of budget information for the UI
class BudgetRepository {
  final AppDatabase _database;

  BudgetRepository(this._database);

  /// Watch all category budgets with real-time expense calculations
  /// Returns a stream that automatically updates when:
  /// - Categories are added/updated/deleted
  /// - Expenses are added/updated/deleted
  Stream<List<CategoryBudgetView>> watchCategoryBudgets() {
    // Combine two streams: categories and expense sums
    return Rx.combineLatest2<List<Category>, Map<int, double>,
        List<CategoryBudgetView>>(
      _database.categoryDao.watchAllCategories(),
      _database.expenseDao.watchExpensesSumByCategory(),
      (categories, expenseSums) {
        return categories.map((category) {
          final totalSpent = expenseSums[category.id] ?? 0.0;
          return CategoryBudgetView(
            category: category,
            totalSpent: totalSpent,
          );
        }).toList();
      },
    );
  }

  /// Watch category budgets filtered by status
  Stream<List<CategoryBudgetView>> watchCategoryBudgetsByStatus(
      BudgetStatus status) {
    return watchCategoryBudgets().map((budgets) {
      return budgets.where((budget) => budget.status == status).toList();
    });
  }

  /// Watch only categories with active budgets (budget > 0)
  Stream<List<CategoryBudgetView>> watchActiveCategoryBudgets() {
    return watchCategoryBudgets().map((budgets) {
      return budgets.where((budget) => !budget.hasNoBudget).toList();
    });
  }

  /// Watch categories sorted by spending (highest first)
  Stream<List<CategoryBudgetView>> watchCategoryBudgetsSortedBySpending() {
    return watchCategoryBudgets().map((budgets) {
      final sorted = List<CategoryBudgetView>.from(budgets);
      sorted.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
      return sorted;
    });
  }

  /// Watch top N spending categories
  Stream<List<CategoryBudgetView>> watchTopSpendingCategories(int limit) {
    return watchCategoryBudgetsSortedBySpending().map((budgets) {
      return budgets.take(limit).toList();
    });
  }

  /// Get total budget across all categories
  Stream<double> watchTotalBudget() {
    return watchCategoryBudgets().map((budgets) {
      return budgets.fold(0.0, (sum, budget) => sum + budget.category.budget);
    });
  }

  /// Get total spent across all categories
  Stream<double> watchTotalSpent() {
    return watchCategoryBudgets().map((budgets) {
      return budgets.fold(0.0, (sum, budget) => sum + budget.totalSpent);
    });
  }

  /// Get total remaining budget
  Stream<double> watchTotalRemaining() {
    return watchCategoryBudgets().map((budgets) {
      return budgets.fold(0.0, (sum, budget) => sum + budget.remaining);
    });
  }

  /// Get overall budget health percentage
  Stream<double> watchOverallBudgetHealth() {
    return Rx.combineLatest2<double, double, double>(
      watchTotalBudget(),
      watchTotalSpent(),
      (totalBudget, totalSpent) {
        if (totalBudget <= 0) return 0.0;
        return (totalSpent / totalBudget * 100);
      },
    );
  }

  /// Get count of categories by status
  Stream<Map<BudgetStatus, int>> watchCategoryCountByStatus() {
    return watchCategoryBudgets().map((budgets) {
      final counts = <BudgetStatus, int>{};
      for (final status in BudgetStatus.values) {
        counts[status] = budgets.where((b) => b.status == status).length;
      }
      return counts;
    });
  }

  /// Non-reactive version - get category budgets once
  Future<List<CategoryBudgetView>> getCategoryBudgets() async {
    final categories = await _database.categoryDao.getAllCategories();
    final expenseSums = await _database.expenseDao.getExpensesSumByCategory();

    return categories.map((category) {
      final totalSpent = expenseSums[category.id] ?? 0.0;
      return CategoryBudgetView(
        category: category,
        totalSpent: totalSpent,
      );
    }).toList();
  }
}
