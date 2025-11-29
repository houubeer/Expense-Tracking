import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/i_category_sort_strategy.dart';

/// Sort categories by spent amount (highest first)
class SpentSortStrategy implements ICategorySortStrategy {
  @override
  String get sortName => 'Spent';

  @override
  int compare(Category a, Category b) {
    return b.spent.compareTo(a.spent);
  }
}
