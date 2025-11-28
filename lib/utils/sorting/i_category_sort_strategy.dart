import 'package:expense_tracking_desktop_app/database/app_database.dart';

/// Interface for category sorting strategies (Open/Closed Principle)
/// New sort methods can be added without modifying existing code
abstract class ICategorySortStrategy {
  String get sortName;
  int compare(Category a, Category b);
}
