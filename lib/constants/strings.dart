/// Application-wide string constants
class AppStrings {
  // Currency
  static const String currency = 'DZD';
  static const String currencyPrefix = 'DZD ';

  // Navigation labels
  static const String navDashboard = 'Dashboard';
  static const String navAddExpense = 'Add Expense';
  static const String navViewExpenses = 'View Expenses';
  static const String navBudgets = 'Budgets';

  // Common buttons
  static const String btnCancel = 'Cancel';
  static const String btnDelete = 'Delete';
  static const String btnSave = 'Save';
  static const String btnAdd = 'Add';
  static const String btnEdit = 'Edit';
  static const String btnClose = 'Close';
  static const String btnUndo = 'Undo';
  static const String btnSaveChanges = 'Save Changes';

  // Screen titles
  static const String titleAddExpense = 'Add Expense';
  static const String titleEditExpense = 'Edit Transaction';
  static const String titleViewExpenses = 'Expenses';
  static const String titleBudgetManagement = 'Budget Management';
  static const String titleAddCategory = 'Add New Category';
  static const String titleDeleteCategory = 'Delete Category';
  static const String titleDeleteTransaction = 'Delete Transaction';

  // Labels
  static const String labelAmount = 'Amount';
  static const String labelCategory = 'Category';
  static const String labelDate = 'Date';
  static const String labelDescription = 'Description';
  static const String labelCategoryName = 'Category Name';
  static const String labelMonthlyBudget = 'Monthly Budget';
  static const String labelColor = 'Color';
  static const String labelIcon = 'Icon';
  static const String labelSpent = 'Spent';
  static const String labelRemaining = 'Remaining';
  static const String labelStatus = 'Status';

  // Status messages
  static const String statusGood = 'Good';
  static const String statusWarning = 'Warning';
  static const String statusInRisk = 'In Risk';

  // Success messages
  static const String msgCategoryAdded = 'Category added successfully';
  static const String msgCategoryUpdated = 'Updated';
  static const String msgCategoryDeleted = 'Category deleted';
  static const String msgExpenseAdded = 'Expense added successfully';
  static const String msgExpenseUpdated = 'Expense updated successfully';
  static const String msgTransactionDeleted = 'Transaction deleted';

  // Error messages
  static const String errBudgetNegative = 'Budget cannot be negative';

  // Hints
  static const String hintSearchCategories = 'Search categories...';
  static const String hintSearchExpenses = 'Search expenses...';

  // Descriptions
  static const String descManageBudgets = 'Manage your categories and budget limits';
  static const String descDeleteCategory = 'Are you sure you want to delete "{name}"? This action cannot be undone.';
  static const String descDeleteTransaction = 'Are you sure you want to delete this transaction? This action cannot be undone.';
  static const String descNoCategoriesFound = 'No categories found.';
  static const String descNoMatchingCategories = 'No categories match your filters';

  // Filter options
  static const String filterAll = 'All';
  static const String filterSortByName = 'Name';
  static const String filterSortByBudget = 'Budget';
  static const String filterSortBySpent = 'Spent';
  static const String filterSortByPercentage = 'Percentage';
}
