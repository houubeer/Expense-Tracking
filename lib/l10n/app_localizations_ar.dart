// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Expense Tracker';

  @override
  String get appTagline => 'Manage your expenses effortlessly';

  @override
  String get appTitle => 'متتبع النفقات';

  @override
  String get titleSignIn => 'تسجيل الدخول إلى حسابك';

  @override
  String get titleManagerDashboard => 'لوحة تحكم المدير';

  @override
  String get descManagerDashboard => 'مراقبة نفقات المنظمة، والموافقة على التعويضات، وإدارة الموظفين.';

  @override
  String get kpiTotalEmployees => 'إجمالي الموظفين';

  @override
  String get kpiTotalExpenses => 'إجمالي النفقات (الشهر)';

  @override
  String get kpiPendingApprovals => 'الموافقات المعلقة';

  @override
  String get labelEmployeeManagement => 'إدارة الموظفين';

  @override
  String get hintSearchEmployees => 'البحث عن موظفين...';

  @override
  String get labelDepartment => 'القسم';

  @override
  String get filterAllDepartments => 'جميع الأقسام';

  @override
  String get labelStatus => 'الحالة';

  @override
  String get filterAllStatuses => 'جميع الحالات';

  @override
  String get labelAddEmployee => 'إضافة موظف';

  @override
  String get labelPendingExpenseApprovals => 'موافقات النفقات المعلقة';

  @override
  String get msgExpenseApproved => 'تمت الموافقة على النفقة بنجاح';

  @override
  String get msgExpenseRejected => 'تم رفض النفقة';

  @override
  String get labelBudgetMonitoring => 'مراقبة الميزانية';

  @override
  String msgEmployeeAdded(String name) {
    return 'تم إضافة الموظف $name';
  }

  @override
  String get msgCommentAdded => 'تم إضافة التعليق بنجاح';

  @override
  String msgViewDetailsFor(String name) {
    return 'عرض التفاصيل لـ $name';
  }

  @override
  String get dialogTitleSuspendEmployee => 'توقيف موظف';

  @override
  String dialogDescSuspendEmployee(String name) {
    return 'هل أنت متأكد أنك تريد توقيف $name؟ لن يتمكن من تقديم النفقات بعد الآن.';
  }

  @override
  String msgEmployeeSuspended(String name) {
    return 'تم توقيف الموظف $name';
  }

  @override
  String msgEmployeeActivated(String name) {
    return 'تم تفعيل الموظف $name';
  }

  @override
  String get dialogTitleRemoveEmployee => 'إزالة موظف';

  @override
  String dialogDescRemoveEmployee(String name) {
    return 'هل أنت متأكد أنك تريد إزالة $name؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String msgEmployeeRemoved(String name) {
    return 'تم إزالة الموظف $name';
  }

  @override
  String get btnCancel => 'إلغاء';

  @override
  String get btnConfirm => 'تأكيد';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get expenses => 'النفقات';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get reports => 'التقارير';

  @override
  String get settings => 'الإعدادات';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get addExpense => 'إضافة نفقة';

  @override
  String get editExpense => 'تعديل النفقة';

  @override
  String get category => 'الفئة';

  @override
  String get amount => 'المبلغ';

  @override
  String get date => 'التاريخ';

  @override
  String get description => 'الوصف';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterFood => 'طعام';

  @override
  String get filterTransport => 'نقل';

  @override
  String get filterShopping => 'تسوق';

  @override
  String get filterEntertainment => 'ترفيه';

  @override
  String get filterHealth => 'صحة';

  @override
  String get filterOther => 'أخرى';

  @override
  String get statusGood => 'جيد';

  @override
  String get statusWarning => 'تحذير';

  @override
  String get statusInRisk => 'في خطر';

  @override
  String get labelSpent => 'تم إنفاقه';

  @override
  String get labelRemaining => 'المتبقي';

  @override
  String get labelMonthlyBudget => 'الميزانية الشهرية';

  @override
  String get titleCategoryBudget => 'حالة ميزانية الفئة';

  @override
  String get titleNoExpenses => 'لم يتم العثور على نفقات';

  @override
  String get colActions => 'الإجراءات';

  @override
  String get titleDeleteTransaction => 'حذف المعاملة';

  @override
  String get descDeleteTransaction => 'هل أنت متأكد أنك تريد حذف هذه المعاملة؟ يمكن التراجع عن هذا الإجراء.';

  @override
  String get btnDelete => 'حذف';

  @override
  String get msgTransactionDeleted => 'تم حذف المعاملة';

  @override
  String errRestoreExpense(String error) {
    return 'فشل في استعادة النفقة: $error';
  }

  @override
  String errDeleteExpense(String error) {
    return 'فشل في حذف النفقة: $error';
  }

  @override
  String get labelReimbursableShort => 'قابل للاسترداد';

  @override
  String get tooltipEditExpense => 'تعديل النفقة';

  @override
  String get tooltipDeleteExpense => 'حذف النفقة';

  @override
  String errPickFile(String error) {
    return 'فشل في اختيار الملف: $error';
  }

  @override
  String get navViewExpenses => 'عرض النفقات';

  @override
  String get errAmountPositive => 'يجب أن يكون المبلغ موجباً';

  @override
  String get errDateFuture => 'لا يمكن أن يكون التاريخ في المستقبل';

  @override
  String get errDatePast => 'التاريخ قديم جداً';

  @override
  String get msgExpenseUpdated => 'تم تحديث النفقة بنجاح';

  @override
  String errUpdateExpense(String error) {
    return 'فشل في تحديث النفقة: $error';
  }

  @override
  String get titleEditExpense => 'تعديل النفقة';

  @override
  String get tooltipClose => 'إغلاق';

  @override
  String get btnUpdateExpense => 'تحديث النفقة';

  @override
  String get btnClose => 'إغلاق';

  @override
  String msgErrorWithParam(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get btnAddExpense => 'إضافة نفقة';

  @override
  String get btnEdit => 'تعديل';

  @override
  String get labelEdit => 'تعديل';

  @override
  String get labelDelete => 'حذف';

  @override
  String get msgExpenseDeleted => 'تم حذف النفقة';

  @override
  String get errAmountRequired => 'يرجى إدخال المبلغ';

  @override
  String get errInvalidNumber => 'يرجى إدخال رقم صالح';

  @override
  String get errCategoryRequired => 'يرجى اختيار فئة';

  @override
  String get errDescriptionRequired => 'يرجى إدخال وصف';

  @override
  String get labelAmount => 'المبلغ';

  @override
  String get labelCategory => 'الفئة';

  @override
  String get labelDate => 'التاريخ';

  @override
  String get labelDescription => 'الوصف';

  @override
  String get labelReimbursable => 'قابل للتعويض';

  @override
  String get labelReimbursableExpense => 'نفقة قابلة للتعويض';

  @override
  String get labelReimbursableHint => 'يمكن استردادها من الشركة';

  @override
  String get labelReceipt => 'الإيصال';

  @override
  String get msgReceiptAttached => 'تم إرفاق الإيصال';

  @override
  String get labelRemoveReceipt => 'إزالة الإيصال';

  @override
  String get labelAttachReceipt => 'إرفاق إيصال';

  @override
  String get btnReset => 'إعادة تعيين';

  @override
  String get msgAddingExpense => 'جاري الإضافة...';

  @override
  String get hintSelectCategory => 'اختر فئة';

  @override
  String get hintDescription => 'ماذا كان هذا من أجل؟';

  @override
  String semanticSelectDate(String date) {
    return 'اختر التاريخ. الحالي: $date';
  }

  @override
  String get currency => 'د.ج';

  @override
  String get filterReimbursable => 'قابل للتعويض';

  @override
  String get filterNonReimbursable => 'غير قابل للتعويض';

  @override
  String get semanticFilter => 'تصفية القائمة';

  @override
  String get semanticAllCategories => 'جميع الفئات';

  @override
  String get filterAllCategories => 'جميع الفئات';

  @override
  String get msgAccountPending => 'حسابك في انتظار الموافقة';

  @override
  String get labelEmail => 'البريد الإلكتروني';

  @override
  String get hintEmail => 'email@example.com';

  @override
  String get errEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get errInvalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get labelPassword => 'كلمة المرور';

  @override
  String get hintPassword => 'أدخل كلمة المرور الخاصة بك';

  @override
  String get errEnterPassword => 'يرجى إدخال كلمة المرور الخاصة بك';

  @override
  String get btnSignIn => 'تسجيل الدخول';

  @override
  String get msgNoAccount => 'ليس لديك حساب؟';

  @override
  String get btnRegisterManager => 'سجل كمدير';

  @override
  String get btnContinueOffline => 'المتابعة بدون اتصال';

  @override
  String get accountDetails => 'تفاصيل الحساب';

  @override
  String get exportReports => 'تصدير التقارير';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get security => 'الأمان';

  @override
  String get backupRestore => 'النسخ الاحتياطي والاستعادة';

  @override
  String get manageAccountPreferences => 'إدارة تفضيلات حسابك';

  @override
  String get viewAndManagePersonalInfo => 'عرض وإدارة معلوماتك الشخصية';

  @override
  String memberSince(String date) {
    return 'عضو منذ $date';
  }

  @override
  String get errGeneric => 'حدث خطأ ما';

  @override
  String get msgCategoryUpdated => 'تم تحديث الملف الشخصي';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get location => 'الموقع';

  @override
  String get downloadExpenseData => 'قم بتنزيل بيانات النفقات الخاصة بك بتنسيق CSV أو PDF';

  @override
  String get filterOptions => 'خيارات التصفية';

  @override
  String get dateRange => 'نطاق التاريخ';

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
  String get customizeAppLook => 'تخصيص مظهر التطبيق على جهازك';

  @override
  String get themeMode => 'وضع السمات';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get system => 'النظام';

  @override
  String get selectPreferredLanguage => 'اختر لغتك المفضلة';

  @override
  String get hintSearchCategories => 'بحث...';

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
  String get newExpenseAdded => 'تم إضافة نفقة جديدة';

  @override
  String get notifyNewExpense => 'احصل على إشعار عند تسجيل نفقة جديدة';

  @override
  String get budgetUpdates => 'تحديثات الميزانية';

  @override
  String get notifyBudgetUpdates => 'احصل على إشعار حول تغييرات حالة الميزانية';

  @override
  String get budgetLimitWarnings => 'تحذيرات حدود الميزانية';

  @override
  String get notifyBudgetLimit => 'تنبيه عند الاقتراب من حدود الميزانية أو تجاوزها';

  @override
  String get weeklySummary => 'ملخص أسبوعي';

  @override
  String get notifyWeeklySummary => 'تلقي تقارير ملخص النفقات الأسبوعية';

  @override
  String get monthlyReports => 'تقارير شهرية';

  @override
  String get notifyMonthlyReports => 'احصل على تقارير مالية شهرية مفصلة';

  @override
  String get quietHours => 'ساعات الهدوء';

  @override
  String get enableQuietHours => 'تفعيل ساعات الهدوء';

  @override
  String get muteNotifications => 'كتم الإشعارات خلال أوقات محددة';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get manageSecurity => 'إدارة إعدادات أمان وخصوصية حسابك';

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
  String get deleteAllDataDesc => 'حذف جميع بيانات النفقات الخاصة بك نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get active => 'نشط';

  @override
  String get reimbursements => 'التعويضات';

  @override
  String get exportExcel => 'تصدير إكسل';

  @override
  String get labelEmployee => 'الموظف';

  @override
  String get labelApprovedAmount => 'المبلغ المعتمد';

  @override
  String get labelPaymentDate => 'تاريخ الدفع';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusUnpaid => 'غير مدفوع';

  @override
  String get labelAddNewEmployee => 'إضافة موظف جديد';

  @override
  String get labelFillEmployeeDetails => 'املأ تفاصيل الموظف أدناه';

  @override
  String get labelRole => 'الدور';

  @override
  String get hintRole => 'مهندس برمجيات';

  @override
  String get errEmployeeNameRequired => 'يرجى إدخال اسم الموظف';

  @override
  String get errPhoneRequired => 'يرجى إدخال رقم الهاتف';

  @override
  String get errRoleRequired => 'يرجى إدخال الدور';

  @override
  String get labelHireDate => 'تاريخ التوظيف';

  @override
  String get labelStatusSuspended => 'موقوف';

  @override
  String get deptEngineering => 'الهندسة';

  @override
  String get deptMarketing => 'التسويق';

  @override
  String get deptSales => 'المبيعات';

  @override
  String get deptProduct => 'المنتج';

  @override
  String get deptDesign => 'التصميم';

  @override
  String get deptHumanResources => 'الموارد البشرية';

  @override
  String get deptFinance => 'المالية';

  @override
  String get btnBackToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get titleRegisterManager => 'تسجيل منظمة';

  @override
  String get subtitleRegisterManager => 'إنشاء حساب منظمة جديد لفريقك';

  @override
  String get labelOrganizationName => 'اسم المنظمة';

  @override
  String get hintOrganizationName => 'Acme Corp';

  @override
  String get errEnterOrganizationName => 'يرجى إدخال اسم المنظمة';

  @override
  String get errOrganizationNameLength => 'يجب أن يكون الاسم 3 أحرف على الأقل';

  @override
  String get labelFullName => 'الاسم الكامل';

  @override
  String get hintFullName => 'فلان الفلاني';

  @override
  String get errEnterFullName => 'يرجى إدخال اسمك الكامل';

  @override
  String get hintCreatePassword => 'أنشئ كلمة مرور آمنة';

  @override
  String get errPasswordLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get labelConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get hintConfirmPassword => 'كرر كلمة المرور الخاصة بك';

  @override
  String get errConfirmPassword => 'يرجى تأكيد كلمة المرور';

  @override
  String get errPasswordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get btnCreateOrganization => 'إنشاء منظمة';

  @override
  String get titleRegistrationSubmitted => 'تم تقديم التسجيل';

  @override
  String msgRegistrationSubmitted(String name) {
    return 'تم تقديم طلبك لـ $name وهو بانتظار موافقة المسؤول.';
  }

  @override
  String get titleWhatHappensNext => 'ماذا يحدث بعد ذلك؟';

  @override
  String get stepReviewRequest => 'يقوم المسؤول بمراجعة طلبك';

  @override
  String get stepAccountActivation => 'تفعيل الحساب بعد الموافقة';

  @override
  String get stepLogin => 'يمكنك بعد ذلك تسجيل الدخول وبدء الإدارة';

  @override
  String get errUserProfileNotFound => 'ملف تعريف المستخدم غير موجود';

  @override
  String get errNoOrganization => 'لا توجد منظمة مرتبطة بهذا الحساب';

  @override
  String msgAddEmployeeSuccess(String name) {
    return 'تم إضافة الموظف $name بنجاح';
  }

  @override
  String errAddEmployee(String error) {
    return 'فشل في إضافة الموظف: $error';
  }

  @override
  String msgRemoveEmployeeConfirm(String name) {
    return 'هل أنت متأكد أنك تريد إزالة $name من الفريق؟';
  }

  @override
  String get actionRemove => 'إزالة';

  @override
  String msgRemoveEmployeeSuccess(String name) {
    return 'تم إزالة الموظف $name بنجاح';
  }

  @override
  String errRemoveEmployee(String error) {
    return 'فشل في إزالة الموظف: $error';
  }

  @override
  String get statusDeactivated => 'تم إلغاء التنشيط';

  @override
  String get statusActivated => 'تم التنشيط';

  @override
  String msgEmployeeStatusChanged(String name, String status) {
    return 'تم تغيير حالة الموظف $name إلى $status';
  }

  @override
  String errUpdateStatus(String error) {
    return 'فشل في تحديث الحالة: $error';
  }

  @override
  String get titleTeamManagement => 'إدارة الفريق';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get titleErrorLoadingEmployees => 'خطأ في تحميل الموظفين';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get titleNoEmployees => 'لا يوجد موظفون بعد';

  @override
  String get msgNoEmployees => 'لم تقم بإضافة أي موظفين إلى فريقك بعد.';

  @override
  String get btnAddFirstEmployee => 'أضف موظفك الأول';

  @override
  String get titleOrganizationManagement => 'إدارة المنظمات';

  @override
  String get tabPending => 'قيد الانتظار';

  @override
  String get tabApproved => 'مقبول';

  @override
  String get tabRejected => 'مرفوض';

  @override
  String msgOrgApproved(String name) {
    return 'تمت الموافقة على المنظمة $name';
  }

  @override
  String errApproveOrg(String error) {
    return 'فشل في الموافقة على المنظمة: $error';
  }

  @override
  String msgOrgRejected(String name) {
    return 'تم رفض المنظمة $name';
  }

  @override
  String errRejectOrg(String error) {
    return 'فشل في رفض المنظمة: $error';
  }

  @override
  String dialogTitleRejectOrg(String name) {
    return 'رفض $name؟';
  }

  @override
  String get labelRejectReason => 'يرجى تقديم سبب الرفض:';

  @override
  String get hintRejectReason => 'سبب الرفض...';

  @override
  String get actionReject => 'رفض';

  @override
  String get errLoadOrgs => 'خطأ في تحميل المنظمات';

  @override
  String get msgNoOrgs => 'لم يتم العثور على منظمات';

  @override
  String get titleExpenseDetails => 'تفاصيل النفقة';

  @override
  String get btnApprove => 'موافقة';

  @override
  String get btnReject => 'رفض';

  @override
  String get btnAddComment => 'إضافة تعليق';

  @override
  String get labelComments => 'التعليقات';

  @override
  String get labelViewReceipt => 'عرض الإيصال';

  @override
  String get titleAddComment => 'إضافة تعليق';

  @override
  String get labelComment => 'تعليق';

  @override
  String get hintComment => 'أدخل تعليقك هنا...';

  @override
  String get errCommentRequired => 'يرجى إدخال تعليق';

  @override
  String get errCommentLength => 'يجب أن يكون التعليق 3 أحرف على الأقل';

  @override
  String get btnSubmit => 'إرسال';

  @override
  String get labelTotal => 'الإجمالي';

  @override
  String get titleNoPendingApprovals => 'لا توجد موافقات معلقة';

  @override
  String get msgAllExpensesProcessed => 'تمت معالجة جميع النفقات';

  @override
  String get tooltipViewDetails => 'عرض التفاصيل';

  @override
  String get tooltipApprove => 'موافقة';

  @override
  String get tooltipReject => 'رفض';

  @override
  String get tooltipComment => 'تعليق';

  @override
  String get titleRejectExpense => 'رفض النفقة';

  @override
  String get labelRejectionReason => 'سبب الرفض';

  @override
  String get hintRejectionReason => 'أدخل سبب الرفض';

  @override
  String get labelViewDetails => 'عرض التفاصيل';

  @override
  String get labelSuspend => 'تعليق';

  @override
  String get labelActivate => 'تفعيل';

  @override
  String get labelRemove => 'إزالة';

  @override
  String get labelBy => 'بواسطة';

  @override
  String get labelStatusActive => 'نشط';

  @override
  String get msgExportExcel => 'جاري التصدير إلى Excel...';

  @override
  String get msgExportPdf => 'جاري التصدير إلى PDF...';

  @override
  String get labelBudget => 'الميزانية';

  @override
  String get labelDescCreateAccount => 'إنشاء حساب جديد لعضو في الفريق';

  @override
  String get labelTemporaryPassword => 'كلمة مرور مؤقتة';

  @override
  String get hintTemporaryPassword => 'إنشاء كلمة مرور مؤقتة';

  @override
  String get msgPasswordChangeHint => 'يمكن للموظف تغيير كلمة المرور هذه بعد تسجيل الدخول الأول.';

  @override
  String get labelDeactivate => 'تعطيل';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get labelUnknown => 'غير معروف';

  @override
  String get ownerDashboard => 'لوحة تحكم المالك';

  @override
  String get subtitleOwnerDashboard => 'إدارة الشركات، الموافقة على المدراء، ومراقبة نشاط المنصة';

  @override
  String get kpiTotalCompanies => 'إجمالي الشركات';

  @override
  String get kpiTotalManagers => 'إجمالي المدراء';

  @override
  String get kpiPendingApprovalsSubtitle => 'مدراء بانتظار الموافقة';

  @override
  String get kpiMonthlyGrowth => 'النمو الشهري';

  @override
  String get kpiMonthlyGrowthSubtitle => 'النمو على مستوى المنصة';

  @override
  String get headerPendingManagerRequests => 'طلبات المدراء المعلقة';

  @override
  String get headerActiveManagers => 'المدراء النشطون';

  @override
  String get headerRecentActivity => 'النشاط الأخير';

  @override
  String get msgNoRecentActivity => 'لم يتم العثور على نشاط أخير';

  @override
  String get msgManagerApproved => 'تمت الموافقة على المدير بنجاح';

  @override
  String get msgManagerRejected => 'تم رفض المدير';

  @override
  String get msgManagerSuspended => 'تم تعليق حساب المدير';

  @override
  String get dialogTitleConfirmDelete => 'تأكيد الحذف';

  @override
  String get dialogDescDeleteManager => 'هل أنت متأكد أنك تريد حذف هذا المدير؟ هذا الإجراء غير قابل للتراجع.';

  @override
  String get msgManagerDeleted => 'تم حذف حساب المدير';

  @override
  String get msgManagerProfileComingSoon => 'عرض ملف المدير سيأتي قريباً';

  @override
  String get dialogTitleRejectManager => 'رفض المدير';

  @override
  String get dialogLabelReasonRejection => 'سبب الرفض';

  @override
  String get dialogHintEnterReason => 'أدخل السبب...';

  @override
  String get dialogActionReject => 'رفض';

  @override
  String get dialogTitleSuspendManager => 'تعليق المدير';

  @override
  String get dialogLabelReasonSuspension => 'سبب التعليق';

  @override
  String get dialogActionSuspend => 'تعليق';

  @override
  String get titleRemoveEmployee => 'إزالة الموظف';

  @override
  String get msgExpenseAdded => 'تمت إضافة النفقة بنجاح';

  @override
  String get navBudgets => 'الميزانيات';

  @override
  String get navManagerDashboard => 'لوحة تحكم المدير';

  @override
  String get titleViewExpenses => 'عرض النفقات';

  @override
  String get subtitleViewExpenses => 'تصفح وإدارة نفقاتك';

  @override
  String get hintSearchExpenses => 'البحث عن نفقات...';

  @override
  String get searchSemanticLabel => 'بحث';

  @override
  String get clearSearchSemanticLabel => 'مسح البحث';

  @override
  String get dashboardSubtitle => 'تتبع إنفاقك وإدارة أموالك';

  @override
  String get numberofCategories => 'الفئات';

  @override
  String get dailyAvgSpending => 'المتوسط اليومي';

  @override
  String get msgCategoryAdded => 'تمت إضافة الفئة بنجاح';

  @override
  String msgAddCategoryFailed(String error) {
    return 'فشل في إضافة الفئة: $error';
  }

  @override
  String get msgCategoryDeleted => 'تم حذف الفئة بنجاح';

  @override
  String msgDeleteCategoryFailed(String error) {
    return 'فشل في حذف الفئة: $error';
  }
}
