import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/utils/sorting/i_category_sort_strategy.dart';

/// Sort categories by percentage used (highest first)
class PercentageSortStrategy implements ICategorySortStrategy {
  @override
  String get sortName => 'Percentage';

  @override
  int compare(Category a, Category b) {
    final aPercentage = a.budget > 0 ? a.spent / a.budget : 0.0;
    final bPercentage = b.budget > 0 ? b.spent / b.budget : 0.0;
    return bPercentage.compareTo(aPercentage);
  }
}
