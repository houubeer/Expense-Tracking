// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع النفقات';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get dashboardSubtitle => 'نظرة عامة على صحتك المالية';

  @override
  String get addExpense => 'إضافة نفقة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get manageAccountPreferences => 'إدارة تفضيلات حسابك وإعدادات التطبيق';

  @override
  String get accountDetails => 'تفاصيل الحساب';

  @override
  String get viewAndManagePersonalInfo => 'عرض وإدارة معلوماتك الشخصية';

  @override
  String memberSince(Object date) {
    return 'عضو منذ $date';
  }

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get location => 'الموقع';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get exportReports => 'تصدير التقارير';

  @override
  String get downloadExpenseData => 'قم بتنزيل بيانات نفقاتك بتنسيق CSV أو PDF';

  @override
  String get filterOptions => 'خيارات التصفية';

  @override
  String get dateRange => 'النطاق الزمني';

  @override
  String get category => 'الفئة';

  @override
  String get exportFormat => 'تنسيق التصدير';

  @override
  String get csvExport => 'تصدير CSV';

  @override
  String get csvExportDesc => 'تنزيل البيانات بتنسيق جدول بيانات (Excel، Google Sheets)';

  @override
  String get exportAsCsv => 'تصدير كـ CSV';

  @override
  String get pdfExport => 'تصدير PDF';

  @override
  String get pdfExportDesc => 'تنزيل تقرير منسق للطباعة أو المشاركة';

  @override
  String get exportAsPdf => 'تصدير كـ PDF';

  @override
  String get appearance => 'المظهر';

  @override
  String get customizeAppLook => 'تخصيص مظهر التطبيق على جهازك';

  @override
  String get themeMode => 'وضع السمة';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get language => 'اللغة';

  @override
  String get selectPreferredLanguage => 'اختر لغتك المفضلة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get manageNotifications => 'إدارة كيفية تلقي الإشعارات';

  @override
  String get notificationChannels => 'قنوات الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get receivePush => 'تلقي الإشعارات على جهازك';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get receiveEmail => 'تلقي التحديثات عبر البريد الإلكتروني';

  @override
  String get notificationTypes => 'أنواع الإشعارات';

  @override
  String get newExpenseAdded => 'تمت إضافة مصروف جديد';

  @override
  String get notifyNewExpense => 'تلقي إشعار عند تسجيل مصروف جديد';

  @override
  String get budgetUpdates => 'تحديثات الميزانية';

  @override
  String get notifyBudgetUpdates => 'تلقي إشعار بتغييرات حالة الميزانية';

  @override
  String get budgetLimitWarnings => 'تحذيرات حد الميزانية';

  @override
  String get notifyBudgetLimit => 'تنبيه عند الاقتراب أو تجاوز حدود الميزانية';

  @override
  String get weeklySummary => 'ملخص أسبوعي';

  @override
  String get notifyWeeklySummary => 'تلقي تقارير ملخص النفقات الأسبوعية';

  @override
  String get monthlyReports => 'تقارير شهرية';

  @override
  String get notifyMonthlyReports => 'الحصول على تقارير مالية شهرية مفصلة';

  @override
  String get quietHours => 'ساعات الصمت';

  @override
  String get enableQuietHours => 'تفعيل ساعات الصمت';

  @override
  String get muteNotifications => 'كتم الإشعارات خلال الأوقات المحددة';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get security => 'الأمان';

  @override
  String get manageSecurity => 'إدارة أمان حسابك وإعدادات الخصوصية';

  @override
  String get password => 'كلمة المرور';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get twoFactorAuth => 'المصادقة الثنائية';

  @override
  String get authenticatorApp => 'تطبيق المصادقة';

  @override
  String get useAuthenticatorApp => 'استخدم تطبيق المصادقة لمزيد من الأمان';

  @override
  String get setUp2fa => 'إعداد المصادقة الثنائية';

  @override
  String get activeSessions => 'الجلسات النشطة';

  @override
  String get signOutOtherSessions => 'تسجيل الخروج من جميع الجلسات الأخرى';

  @override
  String get deleteAllData => 'حذف جميع البيانات';

  @override
  String get deleteAllDataDesc => 'سيتم حذف جميع بيانات نفقاتك نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get backupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get account => 'الحساب';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get numberofCategories => 'عدد الفئات';

  @override
  String get active => 'نشط';

  @override
  String get expenses => 'النفقات';

  @override
  String get dailyAvgSpending => 'متوسط الإنفاق اليومي';

  @override
  String get currency => 'DZD';

  @override
  String get navViewExpenses => 'عرض النفقات';

  @override
  String get navBudgets => 'الميزانيات';

  @override
  String get navManageBudgets => 'إدارة الميزانيات';

  @override
  String get navManagerDashboard => 'لوحة تحكم المدير';

  @override
  String get navViewAll => 'عرض الكل';

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get btnDelete => 'حذف';

  @override
  String get btnSave => 'حفظ';

  @override
  String get btnAdd => 'إضافة';

  @override
  String get btnEdit => 'تعديل';

  @override
  String get btnClose => 'إغلاق';

  @override
  String get btnUndo => 'تراجع';

  @override
  String get btnReset => 'إعادة تعيين';

  @override
  String get btnAddCategory => 'إضافة فئة';

  @override
  String get titleEditExpense => 'تعديل النفقة';

  @override
  String get titleBudgetManagement => 'إدارة الميزانيات';

  @override
  String get titleAddCategory => 'إضافة فئة جديدة';

  @override
  String get titleDeleteCategory => 'حذف الفئة';

  @override
  String get titleDeleteTransaction => 'حذف النفقة';

  @override
  String get titleBudgetOverview => 'نظرة عامة على الميزانية';

  @override
  String get titleRecentExpenses => 'النفقات الأخيرة';

  @override
  String get titleManagerDashboard => 'لوحة تحكم المدير';

  @override
  String get titleEmployeeExpenses => 'نفقات الموظفين';

  @override
  String get labelAmount => 'المبلغ';

  @override
  String get labelDate => 'التاريخ';

  @override
  String get labelDescription => 'الوصف';

  @override
  String get labelCategoryName => 'اسم الفئة';

  @override
  String get labelMonthlyBudget => 'الميزانية الشهرية';

  @override
  String get labelBudget => 'الميزانية';

  @override
  String get labelColor => 'اللون';

  @override
  String get labelIcon => 'الرمز';

  @override
  String get labelSpent => 'المصروف';

  @override
  String get labelRemaining => 'المتبقي';

  @override
  String get labelStatus => 'الحالة';

  @override
  String get statusGood => 'جيد';

  @override
  String get statusWarning => 'تحذير';

  @override
  String get statusInRisk => 'في خطر';

  @override
  String get msgCategoryAdded => 'تمت إضافة الفئة بنجاح';

  @override
  String get msgCategoryUpdated => 'تم التحديث';

  @override
  String get msgCategoryDeleted => 'تم حذف الفئة';

  @override
  String get msgExpenseAdded => 'تمت إضافة النفقة بنجاح';

  @override
  String get msgExpenseUpdated => 'تم تحديث النفقة بنجاح';

  @override
  String get msgTransactionDeleted => 'تم حذف النفقة';

  @override
  String get msgNoExpensesYet => 'لا توجد نفقات حتى الآن';

  @override
  String get msgNoBudgetsYet => 'لم يتم تعيين أي ميزانيات. انتقل إلى الميزانيات لإنشاء واحدة.';

  @override
  String get errBudgetNegative => 'لا يمكن أن تكون الميزانية سالبة';

  @override
  String get hintSearchCategories => 'ابحث عن فئات...';

  @override
  String get hintSearchExpenses => 'ابحث عن نفقات...';

  @override
  String get hintDescription => 'ما الغرض من هذه النفقة؟';

  @override
  String get descManageBudgets => 'إدارة الفئات والحدود الميزانية';

  @override
  String get descManagerDashboard => 'مراقبة الموظفين والموافقة على النفقات والتحكم في الميزانيات';

  @override
  String get descEmployeeExpenses => 'عرض وإدارة طلبات نفقات الموظفين';

  @override
  String descDeleteCategory(Object name) {
    return 'هل أنت متأكد من رغبتك في حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get descDeleteTransaction => 'هل أنت متأكد من رغبتك في حذف هذه النفقة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get descNoCategoriesFound => 'لم يتم العثور على أي فئات.';

  @override
  String get descNoMatchingCategories => 'لا توجد فئات تطابق عوامل التصفية الخاصة بك';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterSortByName => 'الاسم';

  @override
  String get filterSortByBudget => 'الميزانية';

  @override
  String get filterSortBySpent => 'المصروف';

  @override
  String get filterSortByPercentage => 'النسبة المئوية';

  @override
  String get filterReimbursable => 'قابل للاسترجاع';

  @override
  String get filterNonReimbursable => 'غير قابل للاسترجاع';

  @override
  String get labelReimbursable => 'قابل للاسترجاع';

  @override
  String get labelReimbursableExpense => 'تمييز كقابل للاسترجاع';

  @override
  String get labelReimbursableHint => 'تحقق إذا كان يجب استرجاع هذه النفقة من قبل الشركة';

  @override
  String get titleReimbursableSummary => 'النفقات القابلة للاسترجاع';

  @override
  String get labelTotalReimbursable => 'إجمالي قابل للاسترجاع';

  @override
  String get labelPendingReimbursement => 'في انتظار الاسترجاع';

  @override
  String get labelReimbursableOwed => 'المبلغ المستحق';

  @override
  String get msgNoReimbursableExpenses => 'لا توجد نفقات قابلة للاسترجاع';

  @override
  String get labelReceipt => 'الإيصال';

  @override
  String get labelAttachReceipt => 'إرفاق الإيصال';

  @override
  String get labelRemoveReceipt => 'إزالة الإيصال';

  @override
  String get labelViewReceipt => 'عرض الإيصال';

  @override
  String get hintAttachReceipt => 'إرفاق صورة أو PDF كدليل';

  @override
  String get msgReceiptAttached => 'تم إرفاق الإيصال بنجاح';

  @override
  String get msgReceiptRemoved => 'تم إزالة الإيصال';

  @override
  String get errReceiptNotFound => 'ملف الإيصال غير موجود';

  @override
  String get errReceiptInvalidFormat => 'صيغة ملف غير صالحة. يرجى استخدام JPG أو PNG أو PDF';

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
  String get searchSemanticLabel => 'بحث';

  @override
  String get clearSearchSemanticLabel => 'مسح البحث';

  @override
  String get clearSearchTooltip => 'مسح البحث';

  @override
  String sortLabel(Object sort) {
    return 'ترتيب: $sort';
  }
}
