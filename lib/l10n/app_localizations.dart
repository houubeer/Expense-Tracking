import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your expenses effortlessly'**
  String get appTagline;

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @titleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get titleSignIn;

  /// No description provided for @titleManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manager Dashboard'**
  String get titleManagerDashboard;

  /// No description provided for @descManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Monitor organization expenses, approve reimbursements, and manage employees.'**
  String get descManagerDashboard;

  /// No description provided for @kpiTotalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Employees'**
  String get kpiTotalEmployees;

  /// No description provided for @kpiTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses (Month)'**
  String get kpiTotalExpenses;

  /// No description provided for @kpiPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get kpiPendingApprovals;

  /// No description provided for @labelEmployeeManagement.
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get labelEmployeeManagement;

  /// No description provided for @hintSearchEmployees.
  ///
  /// In en, this message translates to:
  /// **'Search employees...'**
  String get hintSearchEmployees;

  /// No description provided for @labelDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get labelDepartment;

  /// No description provided for @filterAllDepartments.
  ///
  /// In en, this message translates to:
  /// **'All Departments'**
  String get filterAllDepartments;

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @filterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get filterAllStatuses;

  /// No description provided for @labelAddEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get labelAddEmployee;

  /// No description provided for @labelPendingExpenseApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Expense Approvals'**
  String get labelPendingExpenseApprovals;

  /// No description provided for @msgExpenseApproved.
  ///
  /// In en, this message translates to:
  /// **'Expense approved successfully'**
  String get msgExpenseApproved;

  /// No description provided for @msgExpenseRejected.
  ///
  /// In en, this message translates to:
  /// **'Expense rejected'**
  String get msgExpenseRejected;

  /// No description provided for @labelBudgetMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Budget Monitoring'**
  String get labelBudgetMonitoring;

  /// No description provided for @msgEmployeeAdded.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} added'**
  String msgEmployeeAdded(String name);

  /// No description provided for @msgCommentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully'**
  String get msgCommentAdded;

  /// No description provided for @msgViewDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'Viewing details for {name}'**
  String msgViewDetailsFor(String name);

  /// No description provided for @dialogTitleSuspendEmployee.
  ///
  /// In en, this message translates to:
  /// **'Suspend Employee'**
  String get dialogTitleSuspendEmployee;

  /// No description provided for @dialogDescSuspendEmployee.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to suspend {name}? They will no longer be able to submit expenses.'**
  String dialogDescSuspendEmployee(String name);

  /// No description provided for @msgEmployeeSuspended.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} suspended'**
  String msgEmployeeSuspended(String name);

  /// No description provided for @msgEmployeeActivated.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} activated'**
  String msgEmployeeActivated(String name);

  /// No description provided for @dialogTitleRemoveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Remove Employee'**
  String get dialogTitleRemoveEmployee;

  /// No description provided for @dialogDescRemoveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name}? This action cannot be undone.'**
  String dialogDescRemoveEmployee(String name);

  /// No description provided for @msgEmployeeRemoved.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} removed'**
  String msgEmployeeRemoved(String name);

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @editExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get filterFood;

  /// No description provided for @filterTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get filterTransport;

  /// No description provided for @filterShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get filterShopping;

  /// No description provided for @filterEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get filterEntertainment;

  /// No description provided for @filterHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get filterHealth;

  /// No description provided for @filterOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get filterOther;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// No description provided for @statusInRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get statusInRisk;

  /// No description provided for @labelSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get labelSpent;

  /// No description provided for @labelRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get labelRemaining;

  /// No description provided for @labelMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get labelMonthlyBudget;

  /// No description provided for @titleCategoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Category Budget Status'**
  String get titleCategoryBudget;

  /// No description provided for @titleNoExpenses.
  ///
  /// In en, this message translates to:
  /// **'No Expenses Found'**
  String get titleNoExpenses;

  /// No description provided for @colActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get colActions;

  /// No description provided for @titleDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get titleDeleteTransaction;

  /// No description provided for @descDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action can be undone.'**
  String get descDeleteTransaction;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @msgTransactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get msgTransactionDeleted;

  /// No description provided for @errRestoreExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore expense: {error}'**
  String errRestoreExpense(String error);

  /// No description provided for @errDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense: {error}'**
  String errDeleteExpense(String error);

  /// No description provided for @labelReimbursableShort.
  ///
  /// In en, this message translates to:
  /// **'Reimbursable'**
  String get labelReimbursableShort;

  /// No description provided for @tooltipEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get tooltipEditExpense;

  /// No description provided for @tooltipDeleteExpense.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get tooltipDeleteExpense;

  /// No description provided for @errPickFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file: {error}'**
  String errPickFile(String error);

  /// No description provided for @navViewExpenses.
  ///
  /// In en, this message translates to:
  /// **'View Expenses'**
  String get navViewExpenses;

  /// No description provided for @errAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be positive'**
  String get errAmountPositive;

  /// No description provided for @errDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Date cannot be in the future'**
  String get errDateFuture;

  /// No description provided for @errDatePast.
  ///
  /// In en, this message translates to:
  /// **'Date is too far in the past'**
  String get errDatePast;

  /// No description provided for @msgExpenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get msgExpenseUpdated;

  /// No description provided for @errUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Failed to update expense: {error}'**
  String errUpdateExpense(String error);

  /// No description provided for @titleEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get titleEditExpense;

  /// No description provided for @tooltipClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tooltipClose;

  /// No description provided for @btnUpdateExpense.
  ///
  /// In en, this message translates to:
  /// **'Update Expense'**
  String get btnUpdateExpense;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @msgErrorWithParam.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String msgErrorWithParam(String error);

  /// No description provided for @btnAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get btnAddExpense;

  /// No description provided for @btnEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// No description provided for @labelEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get labelEdit;

  /// No description provided for @labelDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get labelDelete;

  /// No description provided for @msgExpenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get msgExpenseDeleted;

  /// No description provided for @errAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get errAmountRequired;

  /// No description provided for @errInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get errInvalidNumber;

  /// No description provided for @errCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get errCategoryRequired;

  /// No description provided for @errDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get errDescriptionRequired;

  /// No description provided for @labelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

  /// No description provided for @labelCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get labelCategory;

  /// No description provided for @labelDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get labelDate;

  /// No description provided for @labelDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelDescription;

  /// No description provided for @labelReimbursable.
  ///
  /// In en, this message translates to:
  /// **'Reimbursable'**
  String get labelReimbursable;

  /// No description provided for @labelReimbursableExpense.
  ///
  /// In en, this message translates to:
  /// **'Reimbursable Expense'**
  String get labelReimbursableExpense;

  /// No description provided for @labelReimbursableHint.
  ///
  /// In en, this message translates to:
  /// **'Can be claimed back from company'**
  String get labelReimbursableHint;

  /// No description provided for @labelReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get labelReceipt;

  /// No description provided for @msgReceiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt Attached'**
  String get msgReceiptAttached;

  /// No description provided for @labelRemoveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove Receipt'**
  String get labelRemoveReceipt;

  /// No description provided for @labelAttachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach Receipt'**
  String get labelAttachReceipt;

  /// No description provided for @btnReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get btnReset;

  /// No description provided for @msgAddingExpense.
  ///
  /// In en, this message translates to:
  /// **'Adding...'**
  String get msgAddingExpense;

  /// No description provided for @hintSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get hintSelectCategory;

  /// No description provided for @hintDescription.
  ///
  /// In en, this message translates to:
  /// **'What was this for?'**
  String get hintDescription;

  /// No description provided for @semanticSelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date. Current: {date}'**
  String semanticSelectDate(String date);

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currency;

  /// No description provided for @filterReimbursable.
  ///
  /// In en, this message translates to:
  /// **'Reimbursable'**
  String get filterReimbursable;

  /// No description provided for @filterNonReimbursable.
  ///
  /// In en, this message translates to:
  /// **'Non-Reimbursable'**
  String get filterNonReimbursable;

  /// No description provided for @semanticFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter List'**
  String get semanticFilter;

  /// No description provided for @semanticAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get semanticAllCategories;

  /// No description provided for @filterAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get filterAllCategories;

  /// No description provided for @msgAccountPending.
  ///
  /// In en, this message translates to:
  /// **'Your account is pending approval'**
  String get msgAccountPending;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get hintEmail;

  /// No description provided for @errEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get errEnterEmail;

  /// No description provided for @errInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get errInvalidEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @hintPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get hintPassword;

  /// No description provided for @errEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get errEnterPassword;

  /// No description provided for @btnSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get btnSignIn;

  /// No description provided for @msgNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get msgNoAccount;

  /// No description provided for @btnRegisterManager.
  ///
  /// In en, this message translates to:
  /// **'Register as Manager'**
  String get btnRegisterManager;

  /// No description provided for @btnContinueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue Offline'**
  String get btnContinueOffline;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @exportReports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get exportReports;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @manageAccountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your account preferences'**
  String get manageAccountPreferences;

  /// No description provided for @viewAndManagePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'View and manage your personal information'**
  String get viewAndManagePersonalInfo;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errGeneric;

  /// No description provided for @msgCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get msgCategoryUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @downloadExpenseData.
  ///
  /// In en, this message translates to:
  /// **'Download your expense data in CSV or PDF format'**
  String get downloadExpenseData;

  /// No description provided for @filterOptions.
  ///
  /// In en, this message translates to:
  /// **'Filter Options'**
  String get filterOptions;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @csvExport.
  ///
  /// In en, this message translates to:
  /// **'CSV Export'**
  String get csvExport;

  /// No description provided for @csvExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Download data in spreadsheet format (Excel, Google Sheets)'**
  String get csvExportDesc;

  /// No description provided for @exportAsCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// No description provided for @pdfExport.
  ///
  /// In en, this message translates to:
  /// **'PDF Export'**
  String get pdfExport;

  /// No description provided for @pdfExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Download formatted report for printing or sharing'**
  String get pdfExportDesc;

  /// No description provided for @exportAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// No description provided for @customizeAppLook.
  ///
  /// In en, this message translates to:
  /// **'Customize how the app looks on your device'**
  String get customizeAppLook;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// No description provided for @hintSearchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get hintSearchCategories;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage how you receive notifications'**
  String get manageNotifications;

  /// No description provided for @notificationChannels.
  ///
  /// In en, this message translates to:
  /// **'Notification Channels'**
  String get notificationChannels;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receivePush.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications on your device'**
  String get receivePush;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// No description provided for @receiveEmail.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via email'**
  String get receiveEmail;

  /// No description provided for @notificationTypes.
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// No description provided for @newExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'New Expense Added'**
  String get newExpenseAdded;

  /// No description provided for @notifyNewExpense.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new expense is recorded'**
  String get notifyNewExpense;

  /// No description provided for @budgetUpdates.
  ///
  /// In en, this message translates to:
  /// **'Budget Updates'**
  String get budgetUpdates;

  /// No description provided for @notifyBudgetUpdates.
  ///
  /// In en, this message translates to:
  /// **'Get notified about budget status changes'**
  String get notifyBudgetUpdates;

  /// No description provided for @budgetLimitWarnings.
  ///
  /// In en, this message translates to:
  /// **'Budget Limit Warnings'**
  String get budgetLimitWarnings;

  /// No description provided for @notifyBudgetLimit.
  ///
  /// In en, this message translates to:
  /// **'Alert when approaching or exceeding budget limits'**
  String get notifyBudgetLimit;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @notifyWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Receive weekly expense summary reports'**
  String get notifyWeeklySummary;

  /// No description provided for @monthlyReports.
  ///
  /// In en, this message translates to:
  /// **'Monthly Reports'**
  String get monthlyReports;

  /// No description provided for @notifyMonthlyReports.
  ///
  /// In en, this message translates to:
  /// **'Get detailed monthly financial reports'**
  String get notifyMonthlyReports;

  /// No description provided for @quietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet Hours'**
  String get quietHours;

  /// No description provided for @enableQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Enable Quiet Hours'**
  String get enableQuietHours;

  /// No description provided for @muteNotifications.
  ///
  /// In en, this message translates to:
  /// **'Mute notifications during specified times'**
  String get muteNotifications;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @manageSecurity.
  ///
  /// In en, this message translates to:
  /// **'Manage your account security and privacy settings'**
  String get manageSecurity;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @twoFactorAuth.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuth;

  /// No description provided for @authenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator App'**
  String get authenticatorApp;

  /// No description provided for @useAuthenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator app for additional security'**
  String get useAuthenticatorApp;

  /// No description provided for @setUp2fa.
  ///
  /// In en, this message translates to:
  /// **'Set Up 2FA'**
  String get setUp2fa;

  /// No description provided for @activeSessions.
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get activeSessions;

  /// No description provided for @signOutOtherSessions.
  ///
  /// In en, this message translates to:
  /// **'Sign out all other sessions'**
  String get signOutOtherSessions;

  /// No description provided for @deleteAllData.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get deleteAllData;

  /// No description provided for @deleteAllDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all your expense data. This action cannot be undone.'**
  String get deleteAllDataDesc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @reimbursements.
  ///
  /// In en, this message translates to:
  /// **'Reimbursements'**
  String get reimbursements;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @labelEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get labelEmployee;

  /// No description provided for @labelApprovedAmount.
  ///
  /// In en, this message translates to:
  /// **'Approved Amount'**
  String get labelApprovedAmount;

  /// No description provided for @labelPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get labelPaymentDate;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get statusUnpaid;

  /// No description provided for @labelAddNewEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add New Employee'**
  String get labelAddNewEmployee;

  /// No description provided for @labelFillEmployeeDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the employee details below'**
  String get labelFillEmployeeDetails;

  /// No description provided for @labelRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get labelRole;

  /// No description provided for @hintRole.
  ///
  /// In en, this message translates to:
  /// **'Software Engineer'**
  String get hintRole;

  /// No description provided for @errEmployeeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter employee name'**
  String get errEmployeeNameRequired;

  /// No description provided for @errPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get errPhoneRequired;

  /// No description provided for @errRoleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter role'**
  String get errRoleRequired;

  /// No description provided for @labelHireDate.
  ///
  /// In en, this message translates to:
  /// **'Hire Date'**
  String get labelHireDate;

  /// No description provided for @labelStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get labelStatusSuspended;

  /// No description provided for @deptEngineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get deptEngineering;

  /// No description provided for @deptMarketing.
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get deptMarketing;

  /// No description provided for @deptSales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get deptSales;

  /// No description provided for @deptProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get deptProduct;

  /// No description provided for @deptDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get deptDesign;

  /// No description provided for @deptHumanResources.
  ///
  /// In en, this message translates to:
  /// **'Human Resources'**
  String get deptHumanResources;

  /// No description provided for @deptFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get deptFinance;

  /// No description provided for @btnBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get btnBackToLogin;

  /// No description provided for @titleRegisterManager.
  ///
  /// In en, this message translates to:
  /// **'Register Organization'**
  String get titleRegisterManager;

  /// No description provided for @subtitleRegisterManager.
  ///
  /// In en, this message translates to:
  /// **'Create a new organization account for your team'**
  String get subtitleRegisterManager;

  /// No description provided for @labelOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Organization Name'**
  String get labelOrganizationName;

  /// No description provided for @hintOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Acme Corp'**
  String get hintOrganizationName;

  /// No description provided for @errEnterOrganizationName.
  ///
  /// In en, this message translates to:
  /// **'Please enter organization name'**
  String get errEnterOrganizationName;

  /// No description provided for @errOrganizationNameLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 characters'**
  String get errOrganizationNameLength;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// No description provided for @hintFullName.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get hintFullName;

  /// No description provided for @errEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get errEnterFullName;

  /// No description provided for @hintCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get hintCreatePassword;

  /// No description provided for @errPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errPasswordLength;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get labelConfirmPassword;

  /// No description provided for @hintConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get hintConfirmPassword;

  /// No description provided for @errConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get errConfirmPassword;

  /// No description provided for @errPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errPasswordsDoNotMatch;

  /// No description provided for @btnCreateOrganization.
  ///
  /// In en, this message translates to:
  /// **'Create Organization'**
  String get btnCreateOrganization;

  /// No description provided for @titleRegistrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Registration Submitted'**
  String get titleRegistrationSubmitted;

  /// No description provided for @msgRegistrationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your request for {name} has been submitted and is pending approval by the administrator.'**
  String msgRegistrationSubmitted(String name);

  /// No description provided for @titleWhatHappensNext.
  ///
  /// In en, this message translates to:
  /// **'What happens next?'**
  String get titleWhatHappensNext;

  /// No description provided for @stepReviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Administrator reviews your request'**
  String get stepReviewRequest;

  /// No description provided for @stepAccountActivation.
  ///
  /// In en, this message translates to:
  /// **'Account is activated upon approval'**
  String get stepAccountActivation;

  /// No description provided for @stepLogin.
  ///
  /// In en, this message translates to:
  /// **'You can then log in and start managing'**
  String get stepLogin;

  /// No description provided for @errUserProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'User profile not found'**
  String get errUserProfileNotFound;

  /// No description provided for @errNoOrganization.
  ///
  /// In en, this message translates to:
  /// **'No organization associated with this account'**
  String get errNoOrganization;

  /// No description provided for @msgAddEmployeeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} has been added successfully'**
  String msgAddEmployeeSuccess(String name);

  /// No description provided for @errAddEmployee.
  ///
  /// In en, this message translates to:
  /// **'Failed to add employee: {error}'**
  String errAddEmployee(String error);

  /// No description provided for @msgRemoveEmployeeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from the team?'**
  String msgRemoveEmployeeConfirm(String name);

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @msgRemoveEmployeeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} has been removed successfully'**
  String msgRemoveEmployeeSuccess(String name);

  /// No description provided for @errRemoveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove employee: {error}'**
  String errRemoveEmployee(String error);

  /// No description provided for @statusDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Deactivated'**
  String get statusDeactivated;

  /// No description provided for @statusActivated.
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get statusActivated;

  /// No description provided for @msgEmployeeStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Employee {name} status changed to {status}'**
  String msgEmployeeStatusChanged(String name, String status);

  /// No description provided for @errUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String errUpdateStatus(String error);

  /// No description provided for @titleTeamManagement.
  ///
  /// In en, this message translates to:
  /// **'Team Management'**
  String get titleTeamManagement;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @titleErrorLoadingEmployees.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Employees'**
  String get titleErrorLoadingEmployees;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @titleNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No Employees Yet'**
  String get titleNoEmployees;

  /// No description provided for @msgNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any employees to your team yet.'**
  String get msgNoEmployees;

  /// No description provided for @btnAddFirstEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Employee'**
  String get btnAddFirstEmployee;

  /// No description provided for @titleOrganizationManagement.
  ///
  /// In en, this message translates to:
  /// **'Organization Management'**
  String get titleOrganizationManagement;

  /// No description provided for @tabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get tabPending;

  /// No description provided for @tabApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get tabApproved;

  /// No description provided for @tabRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get tabRejected;

  /// No description provided for @msgOrgApproved.
  ///
  /// In en, this message translates to:
  /// **'Organization {name} has been approved'**
  String msgOrgApproved(String name);

  /// No description provided for @errApproveOrg.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve organization: {error}'**
  String errApproveOrg(String error);

  /// No description provided for @msgOrgRejected.
  ///
  /// In en, this message translates to:
  /// **'Organization {name} has been rejected'**
  String msgOrgRejected(String name);

  /// No description provided for @errRejectOrg.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject organization: {error}'**
  String errRejectOrg(String error);

  /// No description provided for @dialogTitleRejectOrg.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}?'**
  String dialogTitleRejectOrg(String name);

  /// No description provided for @labelRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for rejection:'**
  String get labelRejectReason;

  /// No description provided for @hintRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection...'**
  String get hintRejectReason;

  /// No description provided for @actionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get actionReject;

  /// No description provided for @errLoadOrgs.
  ///
  /// In en, this message translates to:
  /// **'Error loading organizations'**
  String get errLoadOrgs;

  /// No description provided for @msgNoOrgs.
  ///
  /// In en, this message translates to:
  /// **'No organizations found'**
  String get msgNoOrgs;

  /// No description provided for @titleExpenseDetails.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get titleExpenseDetails;

  /// No description provided for @btnApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get btnApprove;

  /// No description provided for @btnReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get btnReject;

  /// No description provided for @btnAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get btnAddComment;

  /// No description provided for @labelComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get labelComments;

  /// No description provided for @labelViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get labelViewReceipt;

  /// No description provided for @titleAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get titleAddComment;

  /// No description provided for @labelComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get labelComment;

  /// No description provided for @hintComment.
  ///
  /// In en, this message translates to:
  /// **'Enter your comment here...'**
  String get hintComment;

  /// No description provided for @errCommentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a comment'**
  String get errCommentRequired;

  /// No description provided for @errCommentLength.
  ///
  /// In en, this message translates to:
  /// **'Comment must be at least 3 characters'**
  String get errCommentLength;

  /// No description provided for @btnSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get btnSubmit;

  /// No description provided for @labelTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get labelTotal;

  /// No description provided for @titleNoPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'No pending approvals'**
  String get titleNoPendingApprovals;

  /// No description provided for @msgAllExpensesProcessed.
  ///
  /// In en, this message translates to:
  /// **'All expenses have been processed'**
  String get msgAllExpensesProcessed;

  /// No description provided for @tooltipViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get tooltipViewDetails;

  /// No description provided for @tooltipApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get tooltipApprove;

  /// No description provided for @tooltipReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get tooltipReject;

  /// No description provided for @tooltipComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get tooltipComment;

  /// No description provided for @titleRejectExpense.
  ///
  /// In en, this message translates to:
  /// **'Reject Expense'**
  String get titleRejectExpense;

  /// No description provided for @labelRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get labelRejectionReason;

  /// No description provided for @hintRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason for rejection'**
  String get hintRejectionReason;

  /// No description provided for @labelViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get labelViewDetails;

  /// No description provided for @labelSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get labelSuspend;

  /// No description provided for @labelActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get labelActivate;

  /// No description provided for @labelRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get labelRemove;

  /// No description provided for @labelBy.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get labelBy;

  /// No description provided for @labelStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get labelStatusActive;

  /// No description provided for @msgExportExcel.
  ///
  /// In en, this message translates to:
  /// **'Exporting to Excel...'**
  String get msgExportExcel;

  /// No description provided for @msgExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Exporting to PDF...'**
  String get msgExportPdf;

  /// No description provided for @labelBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get labelBudget;

  /// No description provided for @labelDescCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a new account for a team member'**
  String get labelDescCreateAccount;

  /// No description provided for @labelTemporaryPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary Password'**
  String get labelTemporaryPassword;

  /// No description provided for @hintTemporaryPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a temporary password'**
  String get hintTemporaryPassword;

  /// No description provided for @msgPasswordChangeHint.
  ///
  /// In en, this message translates to:
  /// **'The employee can change this password after first login.'**
  String get msgPasswordChangeHint;

  /// No description provided for @labelDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get labelDeactivate;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @labelUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get labelUnknown;

  /// No description provided for @ownerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// No description provided for @subtitleOwnerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manage organizations, approve managers, and monitor platform activity'**
  String get subtitleOwnerDashboard;

  /// No description provided for @kpiTotalCompanies.
  ///
  /// In en, this message translates to:
  /// **'Total Companies'**
  String get kpiTotalCompanies;

  /// No description provided for @kpiTotalManagers.
  ///
  /// In en, this message translates to:
  /// **'Total Managers'**
  String get kpiTotalManagers;

  /// No description provided for @kpiPendingApprovalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Managers waiting for approval'**
  String get kpiPendingApprovalsSubtitle;

  /// No description provided for @kpiMonthlyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Monthly Growth'**
  String get kpiMonthlyGrowth;

  /// No description provided for @kpiMonthlyGrowthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide growth'**
  String get kpiMonthlyGrowthSubtitle;

  /// No description provided for @headerPendingManagerRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Manager Requests'**
  String get headerPendingManagerRequests;

  /// No description provided for @headerActiveManagers.
  ///
  /// In en, this message translates to:
  /// **'Active Managers'**
  String get headerActiveManagers;

  /// No description provided for @headerRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get headerRecentActivity;

  /// No description provided for @msgNoRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity found'**
  String get msgNoRecentActivity;

  /// No description provided for @msgManagerApproved.
  ///
  /// In en, this message translates to:
  /// **'Manager approved successfully'**
  String get msgManagerApproved;

  /// No description provided for @msgManagerRejected.
  ///
  /// In en, this message translates to:
  /// **'Manager rejected'**
  String get msgManagerRejected;

  /// No description provided for @msgManagerSuspended.
  ///
  /// In en, this message translates to:
  /// **'Manager account suspended'**
  String get msgManagerSuspended;

  /// No description provided for @dialogTitleConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get dialogTitleConfirmDelete;

  /// No description provided for @dialogDescDeleteManager.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this manager? This action cannot be undone.'**
  String get dialogDescDeleteManager;

  /// No description provided for @msgManagerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Manager account deleted'**
  String get msgManagerDeleted;

  /// No description provided for @msgManagerProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Manager profile view is coming soon'**
  String get msgManagerProfileComingSoon;

  /// No description provided for @dialogTitleRejectManager.
  ///
  /// In en, this message translates to:
  /// **'Reject Manager'**
  String get dialogTitleRejectManager;

  /// No description provided for @dialogLabelReasonRejection.
  ///
  /// In en, this message translates to:
  /// **'Reason for Rejection'**
  String get dialogLabelReasonRejection;

  /// No description provided for @dialogHintEnterReason.
  ///
  /// In en, this message translates to:
  /// **'Enter reason...'**
  String get dialogHintEnterReason;

  /// No description provided for @dialogActionReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get dialogActionReject;

  /// No description provided for @dialogTitleSuspendManager.
  ///
  /// In en, this message translates to:
  /// **'Suspend Manager'**
  String get dialogTitleSuspendManager;

  /// No description provided for @dialogLabelReasonSuspension.
  ///
  /// In en, this message translates to:
  /// **'Reason for Suspension'**
  String get dialogLabelReasonSuspension;

  /// No description provided for @dialogActionSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get dialogActionSuspend;

  /// No description provided for @titleRemoveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Remove Employee'**
  String get titleRemoveEmployee;

  /// No description provided for @msgExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get msgExpenseAdded;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manager Dashboard'**
  String get navManagerDashboard;

  /// No description provided for @titleViewExpenses.
  ///
  /// In en, this message translates to:
  /// **'View Expenses'**
  String get titleViewExpenses;

  /// No description provided for @subtitleViewExpenses.
  ///
  /// In en, this message translates to:
  /// **'Browse and manage your expenses'**
  String get subtitleViewExpenses;

  /// No description provided for @hintSearchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses...'**
  String get hintSearchExpenses;

  /// No description provided for @searchSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchSemanticLabel;

  /// No description provided for @clearSearchSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchSemanticLabel;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your spending and manage your finances'**
  String get dashboardSubtitle;

  /// No description provided for @numberofCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get numberofCategories;

  /// No description provided for @dailyAvgSpending.
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get dailyAvgSpending;

  /// No description provided for @msgCategoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get msgCategoryAdded;

  /// No description provided for @msgAddCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add category: {error}'**
  String msgAddCategoryFailed(String error);

  /// No description provided for @msgCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get msgCategoryDeleted;

  /// No description provided for @msgDeleteCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category: {error}'**
  String msgDeleteCategoryFailed(String error);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
