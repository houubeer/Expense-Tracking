// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Overview of your financial health';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get settings => 'Settings';

  @override
  String get manageAccountPreferences => 'Manage your account preferences and app settings';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get viewAndManagePersonalInfo => 'View and manage your personal information';

  @override
  String memberSince(Object date) {
    return 'Member since $date';
  }

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get location => 'Location';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get exportReports => 'Export Reports';

  @override
  String get downloadExpenseData => 'Download your expense data in CSV or PDF format';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get dateRange => 'Date Range';

  @override
  String get category => 'Category';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get csvExport => 'CSV Export';

  @override
  String get csvExportDesc => 'Download data in spreadsheet format (Excel, Google Sheets)';

  @override
  String get exportAsCsv => 'Export as CSV';

  @override
  String get pdfExport => 'PDF Export';

  @override
  String get pdfExportDesc => 'Download formatted report for printing or sharing';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get appearance => 'Appearance';

  @override
  String get customizeAppLook => 'Customize how the app looks on your device';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get selectPreferredLanguage => 'Select your preferred language';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Manage how you receive notifications';

  @override
  String get notificationChannels => 'Notification Channels';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get receivePush => 'Receive notifications on your device';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get receiveEmail => 'Receive updates via email';

  @override
  String get notificationTypes => 'Notification Types';

  @override
  String get newExpenseAdded => 'New Expense Added';

  @override
  String get notifyNewExpense => 'Get notified when a new expense is recorded';

  @override
  String get budgetUpdates => 'Budget Updates';

  @override
  String get notifyBudgetUpdates => 'Get notified about budget status changes';

  @override
  String get budgetLimitWarnings => 'Budget Limit Warnings';

  @override
  String get notifyBudgetLimit => 'Alert when approaching or exceeding budget limits';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get notifyWeeklySummary => 'Receive weekly expense summary reports';

  @override
  String get monthlyReports => 'Monthly Reports';

  @override
  String get notifyMonthlyReports => 'Get detailed monthly financial reports';

  @override
  String get quietHours => 'Quiet Hours';

  @override
  String get enableQuietHours => 'Enable Quiet Hours';

  @override
  String get muteNotifications => 'Mute notifications during specified times';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get security => 'Security';

  @override
  String get manageSecurity => 'Manage your account security and privacy settings';

  @override
  String get password => 'Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get authenticatorApp => 'Authenticator App';

  @override
  String get useAuthenticatorApp => 'Use an authenticator app for additional security';

  @override
  String get setUp2fa => 'Set Up 2FA';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get signOutOtherSessions => 'Sign out all other sessions';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataDesc => 'Permanently delete all your expense data. This action cannot be undone.';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get account => 'Account';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get numberofCategories => 'Number of Categories';

  @override
  String get active => 'Active';

  @override
  String get expenses => 'Expenses';

  @override
  String get dailyAvgSpending => 'Daily Avg Spending';

  @override
  String get currency => 'DZD';

  @override
  String get navViewExpenses => 'View Expenses';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navManageBudgets => 'Manage Budgets';

  @override
  String get navManagerDashboard => 'Manager Dashboard';

  @override
  String get navViewAll => 'View All';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnSave => 'Save';

  @override
  String get btnAdd => 'Add';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnClose => 'Close';

  @override
  String get btnUndo => 'Undo';

  @override
  String get btnReset => 'Reset';

  @override
  String get btnAddCategory => 'Add Category';

  @override
  String get titleEditExpense => 'Edit Expense';

  @override
  String get titleBudgetManagement => 'Budget Management';

  @override
  String get titleAddCategory => 'Add New Category';

  @override
  String get titleDeleteCategory => 'Delete Category';

  @override
  String get titleDeleteTransaction => 'Delete Expense';

  @override
  String get titleBudgetOverview => 'Budget Overview';

  @override
  String get titleRecentExpenses => 'Recent Expenses';

  @override
  String get titleManagerDashboard => 'Manager Dashboard';

  @override
  String get titleEmployeeExpenses => 'Employee Expenses';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelCategoryName => 'Category Name';

  @override
  String get labelMonthlyBudget => 'Monthly Budget';

  @override
  String get labelBudget => 'Budget';

  @override
  String get labelColor => 'Color';

  @override
  String get labelIcon => 'Icon';

  @override
  String get labelSpent => 'Spent';

  @override
  String get labelRemaining => 'Remaining';

  @override
  String get labelStatus => 'Status';

  @override
  String get statusGood => 'Good';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusInRisk => 'In Risk';

  @override
  String get msgCategoryAdded => 'Category added successfully';

  @override
  String get msgCategoryUpdated => 'Updated';

  @override
  String get msgCategoryDeleted => 'Category deleted';

  @override
  String get msgExpenseAdded => 'Expense added successfully';

  @override
  String get msgExpenseUpdated => 'Expense updated successfully';

  @override
  String get msgTransactionDeleted => 'Expense deleted';

  @override
  String get msgNoExpensesYet => 'No expenses yet';

  @override
  String get msgNoBudgetsYet => 'No budgets set yet. Go to Budgets to create one.';

  @override
  String get errBudgetNegative => 'Budget cannot be negative';

  @override
  String get hintSearchCategories => 'Search categories...';

  @override
  String get hintSearchExpenses => 'Search expenses...';

  @override
  String get hintDescription => 'What was this expense for?';

  @override
  String get descManageBudgets => 'Manage your categories and budget limits';

  @override
  String get descManagerDashboard => 'Monitor employees, approve expenses, and control budgets';

  @override
  String get descEmployeeExpenses => 'View and manage employee expense submissions';

  @override
  String descDeleteCategory(Object name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get descDeleteTransaction => 'Are you sure you want to delete this expense? This action cannot be undone.';

  @override
  String get descNoCategoriesFound => 'No categories found.';

  @override
  String get descNoMatchingCategories => 'No categories match your filters';

  @override
  String get filterAll => 'All';

  @override
  String get filterSortByName => 'Name';

  @override
  String get filterSortByBudget => 'Budget';

  @override
  String get filterSortBySpent => 'Spent';

  @override
  String get filterSortByPercentage => 'Percentage';

  @override
  String get filterReimbursable => 'Reimbursable';

  @override
  String get filterNonReimbursable => 'Non-Reimbursable';

  @override
  String get labelReimbursable => 'Reimbursable';

  @override
  String get labelReimbursableExpense => 'Mark as Reimbursable';

  @override
  String get labelReimbursableHint => 'Check if this expense should be reimbursed by the company';

  @override
  String get titleReimbursableSummary => 'Reimbursable Expenses';

  @override
  String get labelTotalReimbursable => 'Total Reimbursable';

  @override
  String get labelPendingReimbursement => 'Pending Reimbursement';

  @override
  String get labelReimbursableOwed => 'Amount Owed';

  @override
  String get msgNoReimbursableExpenses => 'No reimbursable expenses';

  @override
  String get labelReceipt => 'Receipt';

  @override
  String get labelAttachReceipt => 'Attach Receipt';

  @override
  String get labelRemoveReceipt => 'Remove Receipt';

  @override
  String get labelViewReceipt => 'View Receipt';

  @override
  String get hintAttachReceipt => 'Attach an image or PDF as proof';

  @override
  String get msgReceiptAttached => 'Receipt attached successfully';

  @override
  String get msgReceiptRemoved => 'Receipt removed';

  @override
  String get errReceiptNotFound => 'Receipt file not found';

  @override
  String get errReceiptInvalidFormat => 'Invalid file format. Please use JPG, PNG, or PDF';

  @override
  String get labelBackup => 'Backup';

  @override
  String get labelRestore => 'Restore';

  @override
  String get titleBackupData => 'Backup Data';

  @override
  String get titleRestoreData => 'Restore Data';

  @override
  String get btnBackupNow => 'Backup Now';

  @override
  String get btnRestoreNow => 'Restore Now';

  @override
  String get msgBackupSuccess => 'Backup created successfully';

  @override
  String get msgRestoreSuccess => 'Data restored successfully';

  @override
  String get msgBackupFailed => 'Backup failed';

  @override
  String get msgRestoreFailed => 'Restore failed';

  @override
  String get descBackup => 'Create a backup file of all your expenses and categories';

  @override
  String get descRestore => 'Restore your data from a previous backup file';

  @override
  String get descRestoreWarning => 'Warning: This will replace all current data with the backup data';

  @override
  String get labelChooseBackupLocation => 'Choose backup location';

  @override
  String get labelSelectBackupFile => 'Select backup file';

  @override
  String get ownerDashboard => 'Owner Dashboard';

  @override
  String get subtitleOwnerDashboard => 'Platform-wide overview and management';

  @override
  String get kpiTotalCompanies => 'Total Companies';

  @override
  String get kpiTotalManagers => 'Total Managers';

  @override
  String get kpiTotalEmployees => 'Total Employees';

  @override
  String get kpiTotalExpenses => 'Total Expenses';

  @override
  String get kpiPendingApprovals => 'Pending Approvals';

  @override
  String get kpiPendingApprovalsSubtitle => 'Managers awaiting approval';

  @override
  String get kpiMonthlyGrowth => 'Monthly Growth';

  @override
  String get kpiMonthlyGrowthSubtitle => 'Platform expense growth';

  @override
  String get headerPendingManagerRequests => 'Pending Manager Requests';

  @override
  String get headerActiveManagers => 'Active Managers';

  @override
  String get headerRecentActivity => 'Recent Activity';

  @override
  String get msgNoRecentActivity => 'No recent activity';

  @override
  String get msgManagerApproved => 'Manager approved successfully';

  @override
  String get msgManagerRejected => 'Manager rejected';

  @override
  String get msgManagerSuspended => 'Manager suspended';

  @override
  String get msgManagerDeleted => 'Manager deleted';

  @override
  String get msgManagerProfileComingSoon => 'Manager profile view - Coming soon';

  @override
  String get dialogTitleRejectManager => 'Reject Manager';

  @override
  String get dialogLabelReasonRejection => 'Reason for rejection';

  @override
  String get dialogHintEnterReason => 'Enter reason...';

  @override
  String get dialogActionReject => 'Reject';

  @override
  String get dialogTitleSuspendManager => 'Suspend Manager';

  @override
  String get dialogLabelReasonSuspension => 'Reason for suspension';

  @override
  String get dialogActionSuspend => 'Suspend';

  @override
  String get dialogTitleConfirmDelete => 'Confirm Delete';

  @override
  String get dialogDescDeleteManager => 'Are you sure you want to delete this manager? This action cannot be undone.';

  @override
  String get labelEmployeeManagement => 'Employee Management';

  @override
  String get hintSearchEmployees => 'Search employees...';

  @override
  String get labelDepartment => 'Department';

  @override
  String get filterAllDepartments => 'All Departments';

  @override
  String get filterAllStatuses => 'All Statuses';

  @override
  String get labelStatusSuspended => 'Suspended';

  @override
  String get labelAddEmployee => 'Add Employee';

  @override
  String get labelPendingExpenseApprovals => 'Pending Expense Approvals';

  @override
  String get msgExpenseApproved => 'Expense approved';

  @override
  String get msgExpenseRejected => 'Expense rejected';

  @override
  String get labelBudgetMonitoring => 'Budget Monitoring';

  @override
  String msgEmployeeAdded(Object name) {
    return 'Employee $name added successfully';
  }

  @override
  String get msgCommentAdded => 'Comment added successfully';

  @override
  String msgViewDetailsFor(Object name) {
    return 'View details for $name';
  }

  @override
  String get dialogTitleSuspendEmployee => 'Suspend Employee';

  @override
  String dialogDescSuspendEmployee(Object name) {
    return 'Are you sure you want to suspend $name?';
  }

  @override
  String msgEmployeeSuspended(Object name) {
    return '$name suspended';
  }

  @override
  String msgEmployeeActivated(Object name) {
    return '$name activated';
  }

  @override
  String get dialogTitleRemoveEmployee => 'Remove Employee';

  @override
  String dialogDescRemoveEmployee(Object name) {
    return 'Are you sure you want to remove $name? This action cannot be undone.';
  }

  @override
  String msgEmployeeRemoved(Object name) {
    return '$name removed';
  }

  @override
  String get btnConfirm => 'Confirm';

  @override
  String msgAddCategoryFailed(Object error) {
    return 'Failed to add category: $error';
  }

  @override
  String msgDeleteCategoryFailed(Object error) {
    return 'Failed to delete category: $error';
  }

  @override
  String get searchSemanticLabel => 'Search';

  @override
  String get clearSearchSemanticLabel => 'Clear search';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String sortLabel(Object sort) {
    return 'Sort: $sort';
  }
}
