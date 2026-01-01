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
  static const String navSettings = 'Settings';
  static const String navManageBudgets = 'Manage Budgets';
  static const String navManagerDashboard = 'Manager Dashboard';
  static const String navViewAll = 'View All';

  // Common buttons
  static const String btnCancel = 'Cancel';
  static const String btnDelete = 'Delete';
  static const String btnSave = 'Save';
  static const String btnAdd = 'Add';
  static const String btnEdit = 'Edit';
  static const String btnClose = 'Close';
  static const String btnUndo = 'Undo';
  static const String btnSaveChanges = 'Save Changes';
  static const String btnAddExpense = 'Add Expense';
  static const String btnReset = 'Reset';
  static const String btnAddCategory = 'Add Category';

  // Screen titles
  static const String titleAddExpense = 'Add Expense';
  static const String titleEditExpense = 'Edit Expense';
  static const String titleViewExpenses = 'Expenses';
  static const String titleBudgetManagement = 'Budget Management';
  static const String titleAddCategory = 'Add New Category';
  static const String titleDeleteCategory = 'Delete Category';
  static const String titleDeleteTransaction = 'Delete Expense';
  static const String titleBudgetOverview = 'Budget Overview';
  static const String titleRecentExpenses = 'Recent Expenses';
  static const String titleManagerDashboard = 'Manager Dashboard';
  static const String titleEmployeeExpenses = 'Employee Expenses';

  // Labels
  static const String labelAmount = 'Amount';
  static const String labelCategory = 'Category';
  static const String labelDate = 'Date';
  static const String labelDescription = 'Description';
  static const String labelCategoryName = 'Category Name';
  static const String labelMonthlyBudget = 'Monthly Budget';
  static const String labelBudget = 'Budget';
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
  static const String msgTransactionDeleted = 'Expense deleted';
  static const String msgNoExpensesYet = 'No expenses yet';
  static const String msgNoBudgetsYet =
      'No budgets set yet. Go to Budgets to create one.';

  // Error messages
  static const String errBudgetNegative = 'Budget cannot be negative';

  // Hints
  static const String hintSearchCategories = 'Search categories...';
  static const String hintSearchExpenses = 'Search expenses...';
  static const String hintDescription = 'What was this expense for?';

  // Descriptions
  static const String descManageBudgets =
      'Manage your categories and budget limits';
  static const String descManagerDashboard =
      'Monitor employees, approve expenses, and control budgets';
  static const String descEmployeeExpenses =
      'View and manage employee expense submissions';
  static const String descDeleteCategory =
      'Are you sure you want to delete "{name}"? This action cannot be undone.';
  static const String descDeleteTransaction =
      'Are you sure you want to delete this expense? This action cannot be undone.';
  static const String descNoCategoriesFound = 'No categories found.';
  static const String descNoMatchingCategories =
      'No categories match your filters';

  // Filter options
  static const String filterAll = 'All';
  static const String filterSortByName = 'Name';
  static const String filterSortByBudget = 'Budget';
  static const String filterSortBySpent = 'Spent';
  static const String filterSortByPercentage = 'Percentage';
  static const String filterReimbursable = 'Reimbursable';
  static const String filterNonReimbursable = 'Non-Reimbursable';

  // Reimbursable expense labels
  static const String labelReimbursable = 'Reimbursable';
  static const String labelReimbursableExpense = 'Mark as Reimbursable';
  static const String labelReimbursableHint =
      'Check if this expense should be reimbursed by the company';
  static const String titleReimbursableSummary = 'Reimbursable Expenses';
  static const String labelTotalReimbursable = 'Total Reimbursable';
  static const String labelPendingReimbursement = 'Pending Reimbursement';
  static const String labelReimbursableOwed = 'Amount Owed';
  static const String labelExpenses = 'expenses';
  static const String msgNoReimbursableExpenses = 'No reimbursable expenses';

  // Receipt attachment labels
  static const String labelReceipt = 'Receipt';
  static const String labelAttachReceipt = 'Attach Receipt';
  static const String labelRemoveReceipt = 'Remove Receipt';
  static const String labelViewReceipt = 'View Receipt';
  static const String hintAttachReceipt = 'Attach an image or PDF as proof';
  static const String msgReceiptAttached = 'Receipt attached successfully';
  static const String msgReceiptRemoved = 'Receipt removed';
  static const String errReceiptNotFound = 'Receipt file not found';
  static const String errReceiptInvalidFormat =
      'Invalid file format. Please use JPG, PNG, or PDF';

  // Backup and restore labels
  static const String labelBackup = 'Backup';
  static const String labelRestore = 'Restore';
  static const String titleBackupData = 'Backup Data';
  static const String titleRestoreData = 'Restore Data';
  static const String btnBackupNow = 'Backup Now';
  static const String btnRestoreNow = 'Restore Now';
  static const String msgBackupSuccess = 'Backup created successfully';
  static const String msgRestoreSuccess = 'Data restored successfully';
  static const String msgBackupFailed = 'Backup failed';
  static const String msgRestoreFailed = 'Restore failed';
  static const String descBackup =
      'Create a backup file of all your expenses and categories';
  static const String descRestore =
      'Restore your data from a previous backup file';
  static const String descRestoreWarning =
      'Warning: This will replace all current data with the backup data';
  static const String labelChooseBackupLocation = 'Choose backup location';
  static const String labelSelectBackupFile = 'Select backup file';
}
