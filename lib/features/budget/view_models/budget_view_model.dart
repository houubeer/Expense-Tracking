import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_reader.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_writer.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/utils/budget_status_calculator.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/category_sort_factory.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:expense_tracking_desktop_app/core/validators/category_validators.dart';
import 'package:expense_tracking_desktop_app/core/errors/error_mapper.dart';
import 'package:expense_tracking_desktop_app/core/exceptions.dart';

/// Filter model for budget categories
class BudgetFilter {

  const BudgetFilter({
    this.searchQuery = '',
    this.statusFilter = 'All',
    this.sortBy = 'Name',
  });
  final String searchQuery;
  final String statusFilter;
  final String sortBy;

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

/// ViewModel for budget management - handles ALL business logic, DB operations, and state
class BudgetViewModel extends ChangeNotifier {

  BudgetViewModel(
      this._categoryReader, this._categoryWriter, this._errorReporting,);
  final ICategoryReader _categoryReader;
  final ICategoryWriter _categoryWriter;
  final ErrorReportingService _errorReporting;
  final _logger = LoggerService.instance;
  final Map<int, TextEditingController> _controllers = {};

  /// Get TextEditingController for a category
  /// UI accesses controllers through ViewModel (not managing lifecycle)
  TextEditingController getController(Category category) {
    return _controllers.putIfAbsent(
      category.id,
      () => TextEditingController(text: category.budget.toStringAsFixed(2)),
    );
  }

  /// Stream of all categories from database
  /// UI subscribes to this instead of accessing repository directly
  Stream<List<Category>> watchCategories() {
    return _categoryReader.watchAllCategories();
  }

  /// Stream of filtered and sorted categories
  /// ALL filtering/sorting logic is in ViewModel, UI just displays
  Stream<List<Category>> watchFilteredCategories(BudgetFilter filter) {
    return watchCategories().map((categories) {
      return _applyFiltersAndSort(categories, filter);
    });
  }

  /// Add a new category (business logic in ViewModel)
  Future<void> addCategory({
    required String name,
    required double budget,
    required int color,
    required String iconCodePoint,
  }) async {
    // Validate inputs using centralized validators
    final nameError = CategoryValidators.validateCategoryName(name);
    if (nameError != null) {
      throw ValidationException(nameError);
    }

    final budgetError = CategoryValidators.validateBudget(budget.toString());
    if (budgetError != null) {
      throw ValidationException(budgetError);
    }

    final colorError = CategoryValidators.validateColor(color);
    if (colorError != null) {
      throw ValidationException(colorError);
    }

    final iconError = CategoryValidators.validateIconCodePoint(iconCodePoint);
    if (iconError != null) {
      throw ValidationException(iconError);
    }

    try {
      _logger.info('BudgetViewModel: Adding category - name=$name');
      await _categoryWriter.insertCategory(
        CategoriesCompanion.insert(
          name: name.trim(),
          budget: Value(budget),
          color: color,
          iconCodePoint: iconCodePoint,
        ),
      );
      _logger.info('BudgetViewModel: Category added successfully - name=$name');
    } catch (e, stackTrace) {
      _logger.error('BudgetViewModel: Failed to add category',
          error: e, stackTrace: stackTrace,);

      // Only report unexpected errors
      if (ErrorMapper.shouldReportError(e)) {
        await _errorReporting.reportUIError(
          'BudgetViewModel',
          'addCategory',
          e,
          stackTrace: stackTrace,
          context: {'errorCode': ErrorMapper.getErrorCode(e)},
        );
      }

      // Throw user-friendly error
      throw Exception(ErrorMapper.getUserFriendlyMessage(e));
    }
  }

  /// Delete a category (business logic in ViewModel)
  Future<void> deleteCategory(int categoryId) async {
    try {
      _logger.info('BudgetViewModel: Deleting category - id=$categoryId');
      await _categoryWriter.deleteCategory(categoryId);
      _logger.info(
          'BudgetViewModel: Category deleted successfully - id=$categoryId',);
    } catch (e, stackTrace) {
      _logger.error(
          'BudgetViewModel: Failed to delete category - id=$categoryId',
          error: e,
          stackTrace: stackTrace,);

      // Only report unexpected errors
      if (ErrorMapper.shouldReportError(e)) {
        await _errorReporting.reportUIError(
          'BudgetViewModel',
          'deleteCategory',
          e,
          stackTrace: stackTrace,
          context: {
            'categoryId': categoryId.toString(),
            'errorCode': ErrorMapper.getErrorCode(e),
          },
        );
      }

      // Throw user-friendly error
      throw Exception(ErrorMapper.getUserFriendlyMessage(e));
    }
  }

  /// Private filtering and sorting logic using Strategy Pattern (Open/Closed Principle)
  List<Category> _applyFiltersAndSort(
    List<Category> categories,
    BudgetFilter filter,
  ) {
    // Apply filters
    final filtered = categories.where((cat) {
      // Search filter
      if (filter.searchQuery.isNotEmpty &&
          !cat.name.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        return false;
      }

      // Status filter
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

    // Apply sorting using Strategy Pattern
    final sortStrategy = CategorySortFactory.getStrategy(filter.sortBy);
    filtered.sort(sortStrategy.compare);

    return filtered;
  }

  @override
  void dispose() {
    // ViewModel manages controller lifecycle, not UI
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Provider factory for BudgetViewModel
final budgetViewModelProvider = Provider.autoDispose<BudgetViewModel>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  final errorReporting = ref.watch(errorReportingServiceProvider);
  return BudgetViewModel(repository, repository, errorReporting);
});

/// StateProvider for budget filter
final budgetFilterProvider = StateProvider<BudgetFilter>((ref) {
  return const BudgetFilter();
});
