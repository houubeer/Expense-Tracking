// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Gestionnaire de Dépenses';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get dashboardSubtitle => 'Aperçu de votre santé financière';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get settings => 'Paramètres';

  @override
  String get manageAccountPreferences => 'Gérez vos préférences de compte et les paramètres de l\'application';

  @override
  String get accountDetails => 'Détails du compte';

  @override
  String get viewAndManagePersonalInfo => 'Voir et gérer vos informations personnelles';

  @override
  String memberSince(Object date) {
    return 'Membre depuis $date';
  }

  @override
  String get fullName => 'Nom complet';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get location => 'Emplacement';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get exportReports => 'Exporter les rapports';

  @override
  String get downloadExpenseData => 'Téléchargez vos données de dépenses au format CSV ou PDF';

  @override
  String get filterOptions => 'Options de filtrage';

  @override
  String get dateRange => 'Plage de dates';

  @override
  String get category => 'Catégorie';

  @override
  String get exportFormat => 'Format d\'exportation';

  @override
  String get csvExport => 'Export CSV';

  @override
  String get csvExportDesc => 'Télécharger les données au format tableur (Excel, Google Sheets)';

  @override
  String get exportAsCsv => 'Exporter en CSV';

  @override
  String get pdfExport => 'Export PDF';

  @override
  String get pdfExportDesc => 'Télécharger un rapport formaté pour impression ou partage';

  @override
  String get exportAsPdf => 'Exporter en PDF';

  @override
  String get appearance => 'Apparence';

  @override
  String get customizeAppLook => 'Personnalisez l\'apparence de l\'application sur votre appareil';

  @override
  String get themeMode => 'Mode Thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get language => 'Langue';

  @override
  String get selectPreferredLanguage => 'Sélectionnez votre langue préférée';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Gérez la façon dont vous recevez les notifications';

  @override
  String get notificationChannels => 'Canaux de notification';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get receivePush => 'Recevoir des notifications sur votre appareil';

  @override
  String get emailNotifications => 'Notifications par e-mail';

  @override
  String get receiveEmail => 'Recevoir des mises à jour par e-mail';

  @override
  String get notificationTypes => 'Types de notification';

  @override
  String get newExpenseAdded => 'Nouvelle dépense ajoutée';

  @override
  String get notifyNewExpense => 'Recevez une notification lorsqu\'une nouvelle dépense est enregistrée';

  @override
  String get budgetUpdates => 'Mises à jour du budget';

  @override
  String get notifyBudgetUpdates => 'Recevez des notifications sur les changements de statut du budget';

  @override
  String get budgetLimitWarnings => 'Avertissements de limite de budget';

  @override
  String get notifyBudgetLimit => 'Alerte lors de l\'approche ou du dépassement des limites de budget';

  @override
  String get weeklySummary => 'Résumé hebdomadaire';

  @override
  String get notifyWeeklySummary => 'Recevez des rapports hebdomadaires sur les dépenses';

  @override
  String get monthlyReports => 'Rapports mensuels';

  @override
  String get notifyMonthlyReports => 'Obtenez des rapports financiers mensuels détaillés';

  @override
  String get quietHours => 'Heures silencieuses';

  @override
  String get enableQuietHours => 'Activer les heures silencieuses';

  @override
  String get muteNotifications => 'Couper les notifications pendant les heures spécifiées';

  @override
  String get from => 'De';

  @override
  String get to => 'À';

  @override
  String get security => 'Sécurité';

  @override
  String get manageSecurity => 'Gérez la sécurité et la confidentialité de votre compte';

  @override
  String get password => 'Mot de passe';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get twoFactorAuth => 'Authentification à deux facteurs';

  @override
  String get authenticatorApp => 'Application d\'authentification';

  @override
  String get useAuthenticatorApp => 'Utilisez une application d\'authentification pour plus de sécurité';

  @override
  String get setUp2fa => 'Configurer 2FA';

  @override
  String get activeSessions => 'Sessions actives';

  @override
  String get signOutOtherSessions => 'Déconnecter toutes les autres sessions';

  @override
  String get deleteAllData => 'Supprimer toutes les données';

  @override
  String get deleteAllDataDesc => 'Supprimez définitivement toutes vos données de dépenses. Cette action est irréversible.';

  @override
  String get backupRestore => 'Sauvegarde & Restauration';

  @override
  String get account => 'Compte';

  @override
  String get totalBalance => 'Solde Total';

  @override
  String get numberofCategories => 'Nombre de Catégories';

  @override
  String get active => 'Actif';

  @override
  String get expenses => 'Dépenses';

  @override
  String get dailyAvgSpending => 'Dépense Moyenne Quotidienne';

  @override
  String get currency => 'DZD';

  @override
  String get navViewExpenses => 'Voir les dépenses';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navManageBudgets => 'Gérer les budgets';

  @override
  String get navManagerDashboard => 'Tableau de bord du gestionnaire';

  @override
  String get navViewAll => 'Voir tout';

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get btnSave => 'Enregistrer';

  @override
  String get btnAdd => 'Ajouter';

  @override
  String get btnEdit => 'Modifier';

  @override
  String get btnClose => 'Fermer';

  @override
  String get btnUndo => 'Annuler';

  @override
  String get btnReset => 'Réinitialiser';

  @override
  String get btnAddCategory => 'Ajouter une catégorie';

  @override
  String get titleEditExpense => 'Modifier la dépense';

  @override
  String get titleBudgetManagement => 'Gestion des budgets';

  @override
  String get titleAddCategory => 'Ajouter une nouvelle catégorie';

  @override
  String get titleDeleteCategory => 'Supprimer la catégorie';

  @override
  String get titleDeleteTransaction => 'Supprimer la dépense';

  @override
  String get titleBudgetOverview => 'Aperçu des budgets';

  @override
  String get titleRecentExpenses => 'Dépenses récentes';

  @override
  String get titleManagerDashboard => 'Tableau de bord du gestionnaire';

  @override
  String get titleEmployeeExpenses => 'Dépenses des employés';

  @override
  String get labelAmount => 'Montant';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelCategoryName => 'Nom de la catégorie';

  @override
  String get labelMonthlyBudget => 'Budget mensuel';

  @override
  String get labelBudget => 'Budget';

  @override
  String get labelColor => 'Couleur';

  @override
  String get labelIcon => 'Icône';

  @override
  String get labelSpent => 'Dépensé';

  @override
  String get labelRemaining => 'Restant';

  @override
  String get labelStatus => 'Statut';

  @override
  String get statusGood => 'Bon';

  @override
  String get statusWarning => 'Avertissement';

  @override
  String get statusInRisk => 'À risque';

  @override
  String get msgCategoryAdded => 'Catégorie ajoutée avec succès';

  @override
  String get msgCategoryUpdated => 'Mise à jour';

  @override
  String get msgCategoryDeleted => 'Catégorie supprimée';

  @override
  String get msgExpenseAdded => 'Dépense ajoutée avec succès';

  @override
  String get msgExpenseUpdated => 'Dépense mise à jour avec succès';

  @override
  String get msgTransactionDeleted => 'Dépense supprimée';

  @override
  String get msgNoExpensesYet => 'Pas de dépenses pour le moment';

  @override
  String get msgNoBudgetsYet => 'Aucun budget défini. Allez à Budgets pour en créer un.';

  @override
  String get errBudgetNegative => 'Le budget ne peut pas être négatif';

  @override
  String get hintSearchCategories => 'Rechercher des catégories...';

  @override
  String get hintSearchExpenses => 'Rechercher des dépenses...';

  @override
  String get hintDescription => 'À quoi servait cette dépense ?';

  @override
  String get descManageBudgets => 'Gérez vos catégories et limites de budget';

  @override
  String get descManagerDashboard => 'Surveillez les employés, approuvez les dépenses et contrôlez les budgets';

  @override
  String get descEmployeeExpenses => 'Voir et gérer les soumissions de dépenses des employés';

  @override
  String descDeleteCategory(Object name) {
    return 'Êtes-vous sûr de vouloir supprimer \\\"$name\\\" ? Cette action ne peut pas être annulée.';
  }

  @override
  String get descDeleteTransaction => 'Êtes-vous sûr de vouloir supprimer cette dépense ? Cette action ne peut pas être annulée.';

  @override
  String get descNoCategoriesFound => 'Aucune catégorie trouvée.';

  @override
  String get descNoMatchingCategories => 'Aucune catégorie ne correspond à vos filtres';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterSortByName => 'Nom';

  @override
  String get filterSortByBudget => 'Budget';

  @override
  String get filterSortBySpent => 'Dépensé';

  @override
  String get filterSortByPercentage => 'Pourcentage';

  @override
  String get filterReimbursable => 'Remboursable';

  @override
  String get filterNonReimbursable => 'Non remboursable';

  @override
  String get labelReimbursable => 'Remboursable';

  @override
  String get labelReimbursableExpense => 'Marquer comme remboursable';

  @override
  String get labelReimbursableHint => 'Cochez si cette dépense doit être remboursée par l\'entreprise';

  @override
  String get titleReimbursableSummary => 'Dépenses remboursables';

  @override
  String get labelTotalReimbursable => 'Total remboursable';

  @override
  String get labelPendingReimbursement => 'En attente de remboursement';

  @override
  String get labelReimbursableOwed => 'Montant dû';

  @override
  String get msgNoReimbursableExpenses => 'Aucune dépense remboursable';

  @override
  String get labelReceipt => 'Reçu';

  @override
  String get labelAttachReceipt => 'Joindre un reçu';

  @override
  String get labelRemoveReceipt => 'Supprimer le reçu';

  @override
  String get labelViewReceipt => 'Voir le reçu';

  @override
  String get hintAttachReceipt => 'Joindre une image ou un PDF comme preuve';

  @override
  String get msgReceiptAttached => 'Reçu joint avec succès';

  @override
  String get msgReceiptRemoved => 'Reçu supprimé';

  @override
  String get errReceiptNotFound => 'Fichier de reçu non trouvé';

  @override
  String get errReceiptInvalidFormat => 'Format de fichier invalide. Veuillez utiliser JPG, PNG ou PDF';

  @override
  String get labelBackup => 'Sauvegarde';

  @override
  String get labelRestore => 'Restaurer';

  @override
  String get titleBackupData => 'Sauvegarder les données';

  @override
  String get titleRestoreData => 'Restaurer les données';

  @override
  String get btnBackupNow => 'Sauvegarder maintenant';

  @override
  String get btnRestoreNow => 'Restaurer maintenant';

  @override
  String get msgBackupSuccess => 'Sauvegarde créée avec succès';

  @override
  String get msgRestoreSuccess => 'Données restaurées avec succès';

  @override
  String get msgBackupFailed => 'La sauvegarde a échoué';

  @override
  String get msgRestoreFailed => 'La restauration a échoué';

  @override
  String get descBackup => 'Créer un fichier de sauvegarde de toutes vos dépenses et catégories';

  @override
  String get descRestore => 'Restaurez vos données à partir d\'un fichier de sauvegarde précédent';

  @override
  String get descRestoreWarning => 'Avertissement: Cela remplacera toutes les données actuelles par les données de sauvegarde';

  @override
  String get labelChooseBackupLocation => 'Choisir l\'emplacement de sauvegarde';

  @override
  String get labelSelectBackupFile => 'Sélectionner le fichier de sauvegarde';

  @override
  String get ownerDashboard => 'Tableau de bord du propriétaire';

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
