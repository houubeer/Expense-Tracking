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
  String get titleSignIn => 'Sign in to your account';

  @override
  String get titleManagerDashboard => 'Manager Dashboard';

  @override
  String get descManagerDashboard => 'Monitor organization expenses, approve reimbursements, and manage employees.';

  @override
  String get kpiTotalEmployees => 'Total Employees';

  @override
  String get kpiTotalExpenses => 'Total Expenses (Month)';

  @override
  String get kpiPendingApprovals => 'Pending Approvals';

  @override
  String get labelEmployeeManagement => 'Employee Management';

  @override
  String get hintSearchEmployees => 'Search employees...';

  @override
  String get labelDepartment => 'Department';

  @override
  String get filterAllDepartments => 'All Departments';

  @override
  String get labelStatus => 'Status';

  @override
  String get filterAllStatuses => 'All Statuses';

  @override
  String get labelAddEmployee => 'Add Employee';

  @override
  String get labelPendingExpenseApprovals => 'Pending Expense Approvals';

  @override
  String get msgExpenseApproved => 'Expense approved successfully';

  @override
  String get msgExpenseRejected => 'Expense rejected';

  @override
  String get labelBudgetMonitoring => 'Budget Monitoring';

  @override
  String msgEmployeeAdded(String name) {
    return 'Employee $name added';
  }

  @override
  String get msgCommentAdded => 'Comment added successfully';

  @override
  String msgViewDetailsFor(String name) {
    return 'Viewing details for $name';
  }

  @override
  String get dialogTitleSuspendEmployee => 'Suspend Employee';

  @override
  String dialogDescSuspendEmployee(String name) {
    return 'Are you sure you want to suspend $name? They will no longer be able to submit expenses.';
  }

  @override
  String msgEmployeeSuspended(String name) {
    return 'Employee $name suspended';
  }

  @override
  String msgEmployeeActivated(String name) {
    return 'Employee $name activated';
  }

  @override
  String get dialogTitleRemoveEmployee => 'Remove Employee';

  @override
  String dialogDescRemoveEmployee(String name) {
    return 'Are you sure you want to remove $name? This action cannot be undone.';
  }

  @override
  String msgEmployeeRemoved(String name) {
    return 'Employee $name removed';
  }

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get expenses => 'Expenses';

  @override
  String get budgets => 'Budgets';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get category => 'Category';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get filterAll => 'All';

  @override
  String get filterFood => 'Food';

  @override
  String get filterTransport => 'Transport';

  @override
  String get filterShopping => 'Shopping';

  @override
  String get filterEntertainment => 'Entertainment';

  @override
  String get filterHealth => 'Health';

  @override
  String get filterOther => 'Other';

  @override
  String get statusGood => 'Good';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusInRisk => 'At Risk';

  @override
  String get labelSpent => 'Spent';

  @override
  String get labelRemaining => 'Remaining';

  @override
  String get labelMonthlyBudget => 'Monthly Budget';

  @override
  String get titleCategoryBudget => 'Category Budget Status';

  @override
  String get titleNoExpenses => 'No Expenses Found';

  @override
  String get colActions => 'Actions';

  @override
  String get titleDeleteTransaction => 'Delete Transaction';

  @override
  String get descDeleteTransaction => 'Are you sure you want to delete this transaction? This action can be undone.';

  @override
  String get btnDelete => 'Delete';

  @override
  String get msgTransactionDeleted => 'Transaction deleted';

  @override
  String errRestoreExpense(String error) {
    return 'Failed to restore expense: $error';
  }

  @override
  String errDeleteExpense(String error) {
    return 'Failed to delete expense: $error';
  }

  @override
  String get labelReimbursableShort => 'Reimbursable';

  @override
  String get tooltipEditExpense => 'Edit Expense';

  @override
  String get tooltipDeleteExpense => 'Delete Expense';

  @override
  String errPickFile(String error) {
    return 'Failed to pick file: $error';
  }

  @override
  String get navViewExpenses => 'View Expenses';

  @override
  String get errAmountPositive => 'Amount must be positive';

  @override
  String get errDateFuture => 'Date cannot be in the future';

  @override
  String get errDatePast => 'Date is too far in the past';

  @override
  String get msgExpenseUpdated => 'Expense updated successfully';

  @override
  String errUpdateExpense(String error) {
    return 'Failed to update expense: $error';
  }

  @override
  String get titleEditExpense => 'Edit Expense';

  @override
  String get tooltipClose => 'Close';

  @override
  String get btnUpdateExpense => 'Update Expense';

  @override
  String get btnClose => 'Close';

  @override
  String msgErrorWithParam(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get btnAddExpense => 'Add Expense';

  @override
  String get btnEdit => 'Edit';

  @override
  String get labelEdit => 'Edit';

  @override
  String get labelDelete => 'Delete';

  @override
  String get msgExpenseDeleted => 'Expense deleted';

  @override
  String get errAmountRequired => 'Please enter an amount';

  @override
  String get errInvalidNumber => 'Please enter a valid number';

  @override
  String get errCategoryRequired => 'Please select a category';

  @override
  String get errDescriptionRequired => 'Please enter a description';

  @override
  String get labelAmount => 'Amount';

  @override
  String get labelCategory => 'Category';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelReimbursable => 'Reimbursable';

  @override
  String get labelReimbursableExpense => 'Reimbursable Expense';

  @override
  String get labelReimbursableHint => 'Can be claimed back from company';

  @override
  String get labelReceipt => 'Receipt';

  @override
  String get msgReceiptAttached => 'Receipt Attached';

  @override
  String get labelRemoveReceipt => 'Remove Receipt';

  @override
  String get labelAttachReceipt => 'Attach Receipt';

  @override
  String get btnReset => 'Reset';

  @override
  String get msgAddingExpense => 'Adding...';

  @override
  String get hintSelectCategory => 'Select Category';

  @override
  String get hintDescription => 'What was this for?';

  @override
  String semanticSelectDate(String date) {
    return 'Select Date. Current: $date';
  }

  @override
  String get currency => 'DZD';

  @override
  String get filterReimbursable => 'Reimbursable';

  @override
  String get filterNonReimbursable => 'Non-Reimbursable';

  @override
  String get semanticFilter => 'Filter List';

  @override
  String get semanticAllCategories => 'All Categories';

  @override
  String get filterAllCategories => 'All Categories';

  @override
  String get msgAccountPending => 'Your account is pending approval';

  @override
  String get labelEmail => 'Email';

  @override
  String get hintEmail => 'email@example.com';

  @override
  String get errEnterEmail => 'Please enter your email';

  @override
  String get errInvalidEmail => 'Please enter a valid email';

  @override
  String get labelPassword => 'Password';

  @override
  String get hintPassword => 'Enter your password';

  @override
  String get errEnterPassword => 'Please enter your password';

  @override
  String get btnSignIn => 'Sign In';

  @override
  String get msgNoAccount => 'Don\'t have an account?';

  @override
  String get btnRegisterManager => 'Register as Manager';

  @override
  String get btnContinueOffline => 'Continue Offline';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get exportReports => 'Export Reports';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Security';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get manageAccountPreferences => 'Manage your account preferences';

  @override
  String get viewAndManagePersonalInfo => 'View and manage your personal information';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get errGeneric => 'Something went wrong';

  @override
  String get msgCategoryUpdated => 'Profile updated';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get location => 'Location';

  @override
  String get downloadExpenseData => 'Download your expense data in CSV or PDF format';

  @override
  String get filterOptions => 'Filter Options';

  @override
  String get dateRange => 'Date Range';

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
  String get selectPreferredLanguage => 'Select your preferred language';

  @override
  String get hintSearchCategories => 'Search...';

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
  String get active => 'Active';

  @override
  String get reimbursements => 'Reimbursements';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get labelEmployee => 'Employee';

  @override
  String get labelApprovedAmount => 'Approved Amount';

  @override
  String get labelPaymentDate => 'Payment Date';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusUnpaid => 'Unpaid';

  @override
  String get labelAddNewEmployee => 'Add New Employee';

  @override
  String get labelFillEmployeeDetails => 'Fill in the employee details below';

  @override
  String get labelRole => 'Role';

  @override
  String get hintRole => 'Software Engineer';

  @override
  String get errEmployeeNameRequired => 'Please enter employee name';

  @override
  String get errPhoneRequired => 'Please enter phone number';

  @override
  String get errRoleRequired => 'Please enter role';

  @override
  String get labelHireDate => 'Hire Date';

  @override
  String get labelStatusSuspended => 'Suspended';

  @override
  String get deptEngineering => 'Engineering';

  @override
  String get deptMarketing => 'Marketing';

  @override
  String get deptSales => 'Sales';

  @override
  String get deptProduct => 'Product';

  @override
  String get deptDesign => 'Design';

  @override
  String get deptHumanResources => 'Human Resources';

  @override
  String get deptFinance => 'Finance';

  @override
  String get btnBackToLogin => 'Back to Login';

  @override
  String get titleRegisterManager => 'Register Organization';

  @override
  String get subtitleRegisterManager => 'Create a new organization account for your team';

  @override
  String get labelOrganizationName => 'Organization Name';

  @override
  String get hintOrganizationName => 'Acme Corp';

  @override
  String get errEnterOrganizationName => 'Please enter organization name';

  @override
  String get errOrganizationNameLength => 'Name must be at least 3 characters';

  @override
  String get labelFullName => 'Full Name';

  @override
  String get hintFullName => 'John Doe';

  @override
  String get errEnterFullName => 'Please enter your full name';

  @override
  String get hintCreatePassword => 'Create a secure password';

  @override
  String get errPasswordLength => 'Password must be at least 6 characters';

  @override
  String get labelConfirmPassword => 'Confirm Password';

  @override
  String get hintConfirmPassword => 'Repeat your password';

  @override
  String get errConfirmPassword => 'Please confirm your password';

  @override
  String get errPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get btnCreateOrganization => 'Create Organization';

  @override
  String get titleRegistrationSubmitted => 'Registration Submitted';

  @override
  String msgRegistrationSubmitted(String name) {
    return 'Your request for $name has been submitted and is pending approval by the administrator.';
  }

  @override
  String get titleWhatHappensNext => 'What happens next?';

  @override
  String get stepReviewRequest => 'Administrator reviews your request';

  @override
  String get stepAccountActivation => 'Account is activated upon approval';

  @override
  String get stepLogin => 'You can then log in and start managing';

  @override
  String get errUserProfileNotFound => 'User profile not found';

  @override
  String get errNoOrganization => 'No organization associated with this account';

  @override
  String msgAddEmployeeSuccess(String name) {
    return 'Employee $name has been added successfully';
  }

  @override
  String errAddEmployee(String error) {
    return 'Failed to add employee: $error';
  }

  @override
  String msgRemoveEmployeeConfirm(String name) {
    return 'Are you sure you want to remove $name from the team?';
  }

  @override
  String get actionRemove => 'Remove';

  @override
  String msgRemoveEmployeeSuccess(String name) {
    return 'Employee $name has been removed successfully';
  }

  @override
  String errRemoveEmployee(String error) {
    return 'Failed to remove employee: $error';
  }

  @override
  String get statusDeactivated => 'Deactivated';

  @override
  String get statusActivated => 'Activated';

  @override
  String msgEmployeeStatusChanged(String name, String status) {
    return 'Employee $name status changed to $status';
  }

  @override
  String errUpdateStatus(String error) {
    return 'Failed to update status: $error';
  }

  @override
  String get titleTeamManagement => 'Team Management';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get titleErrorLoadingEmployees => 'Error Loading Employees';

  @override
  String get actionRetry => 'Retry';

  @override
  String get titleNoEmployees => 'No Employees Yet';

  @override
  String get msgNoEmployees => 'You haven\'t added any employees to your team yet.';

  @override
  String get btnAddFirstEmployee => 'Add Your First Employee';

  @override
  String get titleOrganizationManagement => 'Organization Management';

  @override
  String get tabPending => 'Pending';

  @override
  String get tabApproved => 'Approved';

  @override
  String get tabRejected => 'Rejected';

  @override
  String msgOrgApproved(String name) {
    return 'Organization $name has been approved';
  }

  @override
  String errApproveOrg(String error) {
    return 'Failed to approve organization: $error';
  }

  @override
  String msgOrgRejected(String name) {
    return 'Organization $name has been rejected';
  }

  @override
  String errRejectOrg(String error) {
    return 'Failed to reject organization: $error';
  }

  @override
  String dialogTitleRejectOrg(String name) {
    return 'Reject $name?';
  }

  @override
  String get labelRejectReason => 'Please provide a reason for rejection:';

  @override
  String get hintRejectReason => 'Reason for rejection...';

  @override
  String get actionReject => 'Reject';

  @override
  String get errLoadOrgs => 'Error loading organizations';

  @override
  String get msgNoOrgs => 'No organizations found';

  @override
  String get titleExpenseDetails => 'Expense Details';

  @override
  String get btnApprove => 'Approve';

  @override
  String get btnReject => 'Reject';

  @override
  String get btnAddComment => 'Add Comment';

  @override
  String get labelComments => 'Comments';

  @override
  String get labelViewReceipt => 'View Receipt';

  @override
  String get titleAddComment => 'Add Comment';

  @override
  String get labelComment => 'Comment';

  @override
  String get hintComment => 'Enter your comment here...';

  @override
  String get errCommentRequired => 'Please enter a comment';

  @override
  String get errCommentLength => 'Comment must be at least 3 characters';

  @override
  String get btnSubmit => 'Submit';

  @override
  String get labelTotal => 'Total';

  @override
  String get titleNoPendingApprovals => 'No pending approvals';

  @override
  String get msgAllExpensesProcessed => 'All expenses have been processed';

  @override
  String get tooltipViewDetails => 'View Details';

  @override
  String get tooltipApprove => 'Approve';

  @override
  String get tooltipReject => 'Reject';

  @override
  String get tooltipComment => 'Comment';

  @override
  String get titleRejectExpense => 'Reject Expense';

  @override
  String get labelRejectionReason => 'Rejection Reason';

  @override
  String get hintRejectionReason => 'Enter reason for rejection';

  @override
  String get labelViewDetails => 'View Details';

  @override
  String get labelSuspend => 'Suspend';

  @override
  String get labelActivate => 'Activate';

  @override
  String get labelRemove => 'Remove';

  @override
  String get labelBy => 'by';

  @override
  String get labelStatusActive => 'Active';

  @override
  String get msgExportExcel => 'Exporting to Excel...';

  @override
  String get msgExportPdf => 'Exporting to PDF...';

  @override
  String get labelBudget => 'Budget';

  @override
  String get labelDescCreateAccount => 'Create a new account for a team member';

  @override
  String get labelTemporaryPassword => 'Temporary Password';

  @override
  String get hintTemporaryPassword => 'Create a temporary password';

  @override
  String get msgPasswordChangeHint => 'The employee can change this password after first login.';

  @override
  String get labelDeactivate => 'Deactivate';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get labelUnknown => 'Unknown';

  @override
  String get ownerDashboard => 'Owner Dashboard';

  @override
  String get subtitleOwnerDashboard => 'Manage organizations, approve managers, and monitor platform activity';

  @override
  String get kpiTotalCompanies => 'Total Companies';

  @override
  String get kpiTotalManagers => 'Total Managers';

  @override
  String get kpiPendingApprovalsSubtitle => 'Managers waiting for approval';

  @override
  String get kpiMonthlyGrowth => 'Monthly Growth';

  @override
  String get kpiMonthlyGrowthSubtitle => 'Platform-wide growth';

  @override
  String get headerPendingManagerRequests => 'Pending Manager Requests';

  @override
  String get headerActiveManagers => 'Active Managers';

  @override
  String get headerRecentActivity => 'Recent Activity';

  @override
  String get msgNoRecentActivity => 'No recent activity found';

  @override
  String get msgManagerApproved => 'Manager approved successfully';

  @override
  String get msgManagerRejected => 'Manager rejected';

  @override
  String get msgManagerSuspended => 'Manager account suspended';

  @override
  String get dialogTitleConfirmDelete => 'Confirm Delete';

  @override
  String get dialogDescDeleteManager => 'Are you sure you want to delete this manager? This action cannot be undone.';

  @override
  String get msgManagerDeleted => 'Manager account deleted';

  @override
  String get msgManagerProfileComingSoon => 'Manager profile view is coming soon';

  @override
  String get dialogTitleRejectManager => 'Reject Manager';

  @override
  String get dialogLabelReasonRejection => 'Reason for Rejection';

  @override
  String get dialogHintEnterReason => 'Enter reason...';

  @override
  String get dialogActionReject => 'Reject';

  @override
  String get dialogTitleSuspendManager => 'Suspend Manager';

  @override
  String get dialogLabelReasonSuspension => 'Reason for Suspension';

  @override
  String get dialogActionSuspend => 'Suspend';

  @override
  String get titleRemoveEmployee => 'Remove Employee';

  @override
  String get msgExpenseAdded => 'Expense added successfully';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navManagerDashboard => 'Manager Dashboard';

  @override
  String get titleViewExpenses => 'View Expenses';

  @override
  String get subtitleViewExpenses => 'Browse and manage your expenses';

  @override
  String get hintSearchExpenses => 'Search expenses...';

  @override
  String get searchSemanticLabel => 'Search';

  @override
  String get clearSearchSemanticLabel => 'Clear search';

  @override
  String get dashboardSubtitle => 'Track your spending and manage your finances';

  @override
  String get numberofCategories => 'Categories';

  @override
  String get dailyAvgSpending => 'Daily Average';

  @override
  String get msgCategoryAdded => 'Category added successfully';

  @override
  String msgAddCategoryFailed(String error) {
    return 'Failed to add category: $error';
  }

  @override
  String get msgCategoryDeleted => 'Category deleted successfully';

  @override
  String msgDeleteCategoryFailed(String error) {
    return 'Failed to delete category: $error';
  }
}
