import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';
import 'package:drift/drift.dart';

/// Filter model for budget categories
class BudgetFilter {
  final String searchQuery;
  final String statusFilter; // 'All', 'Good', 'Warning', 'In Risk'
  final String sortBy; // 'Name', 'Budget', 'Spent', 'Percentage'

  const BudgetFilter({
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.sortBy = 'Name',
  });

  BudgetFilter copyWith({
    String? searchQuery,
    String? statusFilter,
    String? sortBy,
  }) {
    return BudgetFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// ViewModel for budget filtering and sorting logic
class BudgetViewModel {
  final CategoryRepository _categoryRepository;

  BudgetViewModel(this._categoryRepository);

  /// Add a new category
  Future<void> addCategory({
    required String name,
    required double budget,
    required int color,
    required String iconCodePoint,
  }) async {
    await _categoryRepository.insertCategory(
      CategoriesCompanion.insert(
        name: name,
        budget: Value(budget),
        color: color,
        iconCodePoint: iconCodePoint,
      ),
    );
  }

  /// Delete a category
  Future<void> deleteCategory(int categoryId) async {
    await _categoryRepository.deleteCategory(categoryId);
  }

  /// Apply search, status filter, and sorting to categories
  List<Category> applyFiltersAndSort(
    List<Category> categories,
    BudgetFilter filter,
  ) {
    // Apply filters
    var filtered = categories.where((cat) {
      // Apply search filter
      if (filter.searchQuery.isNotEmpty &&
          !cat.name.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        return false;
      }

      // Apply status filter
      if (filter.statusFilter != 'All') {
        final percentage =
            BudgetStatusCalculator.calculatePercentage(cat.spent, cat.budget);
        final status = BudgetStatusCalculator.getStatusText(percentage);
        if (status != filter.statusFilter) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      switch (filter.sortBy) {
        case 'Budget':
          return b.budget.compareTo(a.budget);
        case 'Spent':
          return b.spent.compareTo(a.spent);
        case 'Percentage':
          final aPercentage =
              BudgetStatusCalculator.calculatePercentage(a.spent, a.budget);
          final bPercentage =
              BudgetStatusCalculator.calculatePercentage(b.spent, b.budget);
          return bPercentage.compareTo(aPercentage);
        case 'Name':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return filtered;
  }
}

/// Provider for BudgetViewModel
final budgetViewModelProvider = Provider<BudgetViewModel>((ref) {
  // This will be provided with the repository when needed
  throw UnimplementedError('BudgetViewModel must be provided with repository');
});

/// StateProvider for budget filter
final budgetFilterProvider = StateProvider<BudgetFilter>((ref) {
  return const BudgetFilter();
});
