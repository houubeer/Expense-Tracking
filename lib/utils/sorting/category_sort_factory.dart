import 'package:expense_tracking_desktop_app/utils/sorting/i_category_sort_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/name_sort_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/budget_sort_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/spent_sort_strategy.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/percentage_sort_strategy.dart';

/// Factory for creating category sort strategies (Open/Closed Principle)
/// To add new sort types, create new strategy class and add to _strategies map
class CategorySortFactory {
  static final Map<String, ICategorySortStrategy> _strategies = {
    'Name': NameSortStrategy(),
    'Budget': BudgetSortStrategy(),
    'Spent': SpentSortStrategy(),
    'Percentage': PercentageSortStrategy(),
  };

  /// Get sort strategy by name
  static ICategorySortStrategy getStrategy(String sortBy) {
    return _strategies[sortBy] ?? NameSortStrategy(); // Default to name sort
  }

  /// Get all available sort options
  static List<String> get availableSorts => _strategies.keys.toList();
}
