/// Budget-specific category operations (ISP - Interface Segregation Principle)
/// Only expense service needs these methods, separated from general CRUD
abstract class ICategoryBudgetManager {
  Future<void> updateCategoryBudget(
      int categoryId, double budget, int currentVersion,);
  Future<void> updateCategorySpent(
      int categoryId, double spent, int currentVersion,);
}
