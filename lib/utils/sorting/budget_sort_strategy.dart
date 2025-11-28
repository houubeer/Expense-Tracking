import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/i_category_sort_strategy.dart';

/// Sort categories by budget amount (highest first)
class BudgetSortStrategy implements ICategorySortStrategy {
  @override
  String get sortName => 'Budget';

  @override
  int compare(Category a, Category b) {
    return b.budget.compareTo(a.budget);
  }
}
