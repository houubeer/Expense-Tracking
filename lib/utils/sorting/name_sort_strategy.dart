import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/i_category_sort_strategy.dart';

/// Sort categories by name (alphabetically)
class NameSortStrategy implements ICategorySortStrategy {
  @override
  String get sortName => 'Name';

  @override
  int compare(Category a, Category b) {
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }
}
