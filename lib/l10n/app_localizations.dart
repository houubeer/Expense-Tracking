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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of your financial health'**
  String get dashboardSubtitle;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @manageAccountPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage your account preferences and app settings'**
  String get manageAccountPreferences;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @viewAndManagePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'View and manage your personal information'**
  String get viewAndManagePersonalInfo;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(Object date);

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

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @exportReports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get exportReports;

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

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

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

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectPreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get selectPreferredLanguage;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

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

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

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

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @numberofCategories.
  ///
  /// In en, this message translates to:
  /// **'Number of Categories'**
  String get numberofCategories;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @dailyAvgSpending.
  ///
  /// In en, this message translates to:
  /// **'Daily Avg Spending'**
  String get dailyAvgSpending;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currency;

  /// No description provided for @navViewExpenses.
  ///
  /// In en, this message translates to:
  /// **'View Expenses'**
  String get navViewExpenses;

  /// No description provided for @navBudgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// No description provided for @navManageBudgets.
  ///
  /// In en, this message translates to:
  /// **'Manage Budgets'**
  String get navManageBudgets;

  /// No description provided for @navManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manager Dashboard'**
  String get navManagerDashboard;

  /// No description provided for @navViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get navViewAll;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btnAdd;

  /// No description provided for @btnEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// No description provided for @btnClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// No description provided for @btnUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get btnUndo;

  /// No description provided for @btnReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get btnReset;

  /// No description provided for @btnAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get btnAddCategory;

  /// No description provided for @titleEditExpense.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get titleEditExpense;

  /// No description provided for @titleBudgetManagement.
  ///
  /// In en, this message translates to:
  /// **'Budget Management'**
  String get titleBudgetManagement;

  /// No description provided for @titleAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add New Category'**
  String get titleAddCategory;

  /// No description provided for @titleDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get titleDeleteCategory;

  /// No description provided for @titleDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get titleDeleteTransaction;

  /// No description provided for @titleBudgetOverview.
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get titleBudgetOverview;

  /// No description provided for @titleRecentExpenses.
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get titleRecentExpenses;

  /// No description provided for @titleManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Manager Dashboard'**
  String get titleManagerDashboard;

  /// No description provided for @titleEmployeeExpenses.
  ///
  /// In en, this message translates to:
  /// **'Employee Expenses'**
  String get titleEmployeeExpenses;

  /// No description provided for @labelAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get labelAmount;

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

  /// No description provided for @labelCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get labelCategoryName;

  /// No description provided for @labelMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get labelMonthlyBudget;

  /// No description provided for @labelBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get labelBudget;

  /// No description provided for @labelColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get labelColor;

  /// No description provided for @labelIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get labelIcon;

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

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

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
  /// **'In Risk'**
  String get statusInRisk;

  /// No description provided for @msgCategoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get msgCategoryAdded;

  /// No description provided for @msgCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get msgCategoryUpdated;

  /// No description provided for @msgCategoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get msgCategoryDeleted;

  /// No description provided for @msgExpenseAdded.
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get msgExpenseAdded;

  /// No description provided for @msgExpenseUpdated.
  ///
  /// In en, this message translates to:
  /// **'Expense updated successfully'**
  String get msgExpenseUpdated;

  /// No description provided for @msgTransactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get msgTransactionDeleted;

  /// No description provided for @msgNoExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get msgNoExpensesYet;

  /// No description provided for @msgNoBudgetsYet.
  ///
  /// In en, this message translates to:
  /// **'No budgets set yet. Go to Budgets to create one.'**
  String get msgNoBudgetsYet;

  /// No description provided for @errBudgetNegative.
  ///
  /// In en, this message translates to:
  /// **'Budget cannot be negative'**
  String get errBudgetNegative;

  /// No description provided for @hintSearchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get hintSearchCategories;

  /// No description provided for @hintSearchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses...'**
  String get hintSearchExpenses;

  /// No description provided for @hintDescription.
  ///
  /// In en, this message translates to:
  /// **'What was this expense for?'**
  String get hintDescription;

  /// No description provided for @descManageBudgets.
  ///
  /// In en, this message translates to:
  /// **'Manage your categories and budget limits'**
  String get descManageBudgets;

  /// No description provided for @descManagerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Monitor employees, approve expenses, and control budgets'**
  String get descManagerDashboard;

  /// No description provided for @descEmployeeExpenses.
  ///
  /// In en, this message translates to:
  /// **'View and manage employee expense submissions'**
  String get descEmployeeExpenses;

  /// No description provided for @descDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String descDeleteCategory(Object name);

  /// No description provided for @descDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense? This action cannot be undone.'**
  String get descDeleteTransaction;

  /// No description provided for @descNoCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found.'**
  String get descNoCategoriesFound;

  /// No description provided for @descNoMatchingCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories match your filters'**
  String get descNoMatchingCategories;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterSortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get filterSortByName;

  /// No description provided for @filterSortByBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get filterSortByBudget;

  /// No description provided for @filterSortBySpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get filterSortBySpent;

  /// No description provided for @filterSortByPercentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get filterSortByPercentage;

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

  /// No description provided for @labelReimbursable.
  ///
  /// In en, this message translates to:
  /// **'Reimbursable'**
  String get labelReimbursable;

  /// No description provided for @labelReimbursableExpense.
  ///
  /// In en, this message translates to:
  /// **'Mark as Reimbursable'**
  String get labelReimbursableExpense;

  /// No description provided for @labelReimbursableHint.
  ///
  /// In en, this message translates to:
  /// **'Check if this expense should be reimbursed by the company'**
  String get labelReimbursableHint;

  /// No description provided for @titleReimbursableSummary.
  ///
  /// In en, this message translates to:
  /// **'Reimbursable Expenses'**
  String get titleReimbursableSummary;

  /// No description provided for @labelTotalReimbursable.
  ///
  /// In en, this message translates to:
  /// **'Total Reimbursable'**
  String get labelTotalReimbursable;

  /// No description provided for @labelPendingReimbursement.
  ///
  /// In en, this message translates to:
  /// **'Pending Reimbursement'**
  String get labelPendingReimbursement;

  /// No description provided for @labelReimbursableOwed.
  ///
  /// In en, this message translates to:
  /// **'Amount Owed'**
  String get labelReimbursableOwed;

  /// No description provided for @msgNoReimbursableExpenses.
  ///
  /// In en, this message translates to:
  /// **'No reimbursable expenses'**
  String get msgNoReimbursableExpenses;

  /// No description provided for @labelReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get labelReceipt;

  /// No description provided for @labelAttachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach Receipt'**
  String get labelAttachReceipt;

  /// No description provided for @labelRemoveReceipt.
  ///
  /// In en, this message translates to:
  /// **'Remove Receipt'**
  String get labelRemoveReceipt;

  /// No description provided for @labelViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get labelViewReceipt;

  /// No description provided for @hintAttachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach an image or PDF as proof'**
  String get hintAttachReceipt;

  /// No description provided for @msgReceiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt attached successfully'**
  String get msgReceiptAttached;

  /// No description provided for @msgReceiptRemoved.
  ///
  /// In en, this message translates to:
  /// **'Receipt removed'**
  String get msgReceiptRemoved;

  /// No description provided for @errReceiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt file not found'**
  String get errReceiptNotFound;

  /// No description provided for @errReceiptInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format. Please use JPG, PNG, or PDF'**
  String get errReceiptInvalidFormat;

  /// No description provided for @labelBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get labelBackup;

  /// No description provided for @labelRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get labelRestore;

  /// No description provided for @titleBackupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get titleBackupData;

  /// No description provided for @titleRestoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get titleRestoreData;

  /// No description provided for @btnBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get btnBackupNow;

  /// No description provided for @btnRestoreNow.
  ///
  /// In en, this message translates to:
  /// **'Restore Now'**
  String get btnRestoreNow;

  /// No description provided for @msgBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get msgBackupSuccess;

  /// No description provided for @msgRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get msgRestoreSuccess;

  /// No description provided for @msgBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get msgBackupFailed;

  /// No description provided for @msgRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get msgRestoreFailed;

  /// No description provided for @descBackup.
  ///
  /// In en, this message translates to:
  /// **'Create a backup file of all your expenses and categories'**
  String get descBackup;

  /// No description provided for @descRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore your data from a previous backup file'**
  String get descRestore;

  /// No description provided for @descRestoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: This will replace all current data with the backup data'**
  String get descRestoreWarning;

  /// No description provided for @labelChooseBackupLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose backup location'**
  String get labelChooseBackupLocation;

  /// No description provided for @labelSelectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select backup file'**
  String get labelSelectBackupFile;

  /// No description provided for @ownerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// No description provided for @subtitleOwnerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Platform-wide overview and management'**
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

  /// No description provided for @kpiTotalEmployees.
  ///
  /// In en, this message translates to:
  /// **'Total Employees'**
  String get kpiTotalEmployees;

  /// No description provided for @kpiTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get kpiTotalExpenses;

  /// No description provided for @kpiPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending Approvals'**
  String get kpiPendingApprovals;

  /// No description provided for @kpiPendingApprovalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Managers awaiting approval'**
  String get kpiPendingApprovalsSubtitle;

  /// No description provided for @kpiMonthlyGrowth.
  ///
  /// In en, this message translates to:
  /// **'Monthly Growth'**
  String get kpiMonthlyGrowth;

  /// No description provided for @kpiMonthlyGrowthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Platform expense growth'**
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
  /// **'No recent activity'**
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
  /// **'Manager suspended'**
  String get msgManagerSuspended;

  /// No description provided for @msgManagerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Manager deleted'**
  String get msgManagerDeleted;

  /// No description provided for @msgManagerProfileComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Manager profile view - Coming soon'**
  String get msgManagerProfileComingSoon;

  /// No description provided for @dialogTitleRejectManager.
  ///
  /// In en, this message translates to:
  /// **'Reject Manager'**
  String get dialogTitleRejectManager;

  /// No description provided for @dialogLabelReasonRejection.
  ///
  /// In en, this message translates to:
  /// **'Reason for rejection'**
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
  /// **'Reason for suspension'**
  String get dialogLabelReasonSuspension;

  /// No description provided for @dialogActionSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend'**
  String get dialogActionSuspend;

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

  /// No description provided for @filterAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get filterAllStatuses;

  /// No description provided for @labelStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get labelStatusSuspended;

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
  /// **'Expense approved'**
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
  /// **'Employee {name} added successfully'**
  String msgEmployeeAdded(Object name);

  /// No description provided for @msgCommentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully'**
  String get msgCommentAdded;

  /// No description provided for @msgViewDetailsFor.
  ///
  /// In en, this message translates to:
  /// **'View details for {name}'**
  String msgViewDetailsFor(Object name);

  /// No description provided for @dialogTitleSuspendEmployee.
  ///
  /// In en, this message translates to:
  /// **'Suspend Employee'**
  String get dialogTitleSuspendEmployee;

  /// No description provided for @dialogDescSuspendEmployee.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to suspend {name}?'**
  String dialogDescSuspendEmployee(Object name);

  /// No description provided for @msgEmployeeSuspended.
  ///
  /// In en, this message translates to:
  /// **'{name} suspended'**
  String msgEmployeeSuspended(Object name);

  /// No description provided for @msgEmployeeActivated.
  ///
  /// In en, this message translates to:
  /// **'{name} activated'**
  String msgEmployeeActivated(Object name);

  /// No description provided for @dialogTitleRemoveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Remove Employee'**
  String get dialogTitleRemoveEmployee;

  /// No description provided for @dialogDescRemoveEmployee.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name}? This action cannot be undone.'**
  String dialogDescRemoveEmployee(Object name);

  /// No description provided for @msgEmployeeRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String msgEmployeeRemoved(Object name);

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @msgAddCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add category: {error}'**
  String msgAddCategoryFailed(Object error);

  /// No description provided for @msgDeleteCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete category: {error}'**
  String msgDeleteCategoryFailed(Object error);

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

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// Prefix for sorting dropdown. Example: 'Sort: Name'
  ///
  /// In en, this message translates to:
  /// **'Sort: {sort}'**
  String sortLabel(Object sort);
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
