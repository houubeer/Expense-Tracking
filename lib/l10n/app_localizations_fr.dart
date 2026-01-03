// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Expense Tracker';

  @override
  String get appTagline => 'Manage your expenses effortlessly';

  @override
  String get appTitle => 'Suivi des Dépenses';

  @override
  String get titleSignIn => 'Connectez-vous à votre compte';

  @override
  String get titleManagerDashboard => 'Tableau de Bord Gestionnaire';

  @override
  String get descManagerDashboard => 'Surveillez les dépenses de l\'organisation, approuvez les remboursements et gérez les employés.';

  @override
  String get kpiTotalEmployees => 'Total Employés';

  @override
  String get kpiTotalExpenses => 'Total Dépenses (Mois)';

  @override
  String get kpiPendingApprovals => 'Approbations en attente';

  @override
  String get labelEmployeeManagement => 'Gestion des Employés';

  @override
  String get hintSearchEmployees => 'Rechercher des employés...';

  @override
  String get labelDepartment => 'Département';

  @override
  String get filterAllDepartments => 'Tous les départements';

  @override
  String get labelStatus => 'Statut';

  @override
  String get filterAllStatuses => 'Tous les statuts';

  @override
  String get labelAddEmployee => 'Ajouter un employé';

  @override
  String get labelPendingExpenseApprovals => 'Approbations de dépenses en attente';

  @override
  String get msgExpenseApproved => 'Dépense approuvée avec succès';

  @override
  String get msgExpenseRejected => 'Dépense rejetée';

  @override
  String get labelBudgetMonitoring => 'Suivi du Budget';

  @override
  String msgEmployeeAdded(String name) {
    return 'Employé $name ajouté';
  }

  @override
  String get msgCommentAdded => 'Commentaire ajouté avec succès';

  @override
  String msgViewDetailsFor(String name) {
    return 'Affichage des détails pour $name';
  }

  @override
  String get dialogTitleSuspendEmployee => 'Suspendre l\'employé';

  @override
  String dialogDescSuspendEmployee(String name) {
    return 'Êtes-vous sûr de vouloir suspendre $name ? Il ne pourra plus soumettre de dépenses.';
  }

  @override
  String msgEmployeeSuspended(String name) {
    return 'Employé $name suspendu';
  }

  @override
  String msgEmployeeActivated(String name) {
    return 'Employé $name activé';
  }

  @override
  String get dialogTitleRemoveEmployee => 'Supprimer l\'employé';

  @override
  String dialogDescRemoveEmployee(String name) {
    return 'Êtes-vous sûr de vouloir supprimer $name ? Cette action est irréversible.';
  }

  @override
  String msgEmployeeRemoved(String name) {
    return 'Employé $name supprimé';
  }

  @override
  String get btnCancel => 'Annuler';

  @override
  String get btnConfirm => 'Confirmer';

  @override
  String get dashboard => 'Tableau de Bord';

  @override
  String get expenses => 'Dépenses';

  @override
  String get budgets => 'Budgets';

  @override
  String get reports => 'Rapports';

  @override
  String get settings => 'Paramètres';

  @override
  String get totalBalance => 'Solde Total';

  @override
  String get monthlyBudget => 'Budget Mensuel';

  @override
  String get recentTransactions => 'Transactions Récentes';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get editExpense => 'Modifier la dépense';

  @override
  String get category => 'Catégorie';

  @override
  String get amount => 'Montant';

  @override
  String get date => 'Date';

  @override
  String get description => 'Description';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterFood => 'Alimentation';

  @override
  String get filterTransport => 'Transport';

  @override
  String get filterShopping => 'Shopping';

  @override
  String get filterEntertainment => 'Divertissement';

  @override
  String get filterHealth => 'Santé';

  @override
  String get filterOther => 'Autre';

  @override
  String get statusGood => 'Bon';

  @override
  String get statusWarning => 'Avertissement';

  @override
  String get statusInRisk => 'En Risque';

  @override
  String get labelSpent => 'Dépensé';

  @override
  String get labelRemaining => 'Restant';

  @override
  String get labelMonthlyBudget => 'Budget Mensuel';

  @override
  String get titleCategoryBudget => 'Statut du Budget par Catégorie';

  @override
  String get titleNoExpenses => 'Aucune Dépense Trouvée';

  @override
  String get colActions => 'Actions';

  @override
  String get titleDeleteTransaction => 'Supprimer la Transaction';

  @override
  String get descDeleteTransaction => 'Êtes-vous sûr de vouloir supprimer cette transaction ? Cette action peut être annulée.';

  @override
  String get btnDelete => 'Supprimer';

  @override
  String get msgTransactionDeleted => 'Transaction supprimée';

  @override
  String errRestoreExpense(String error) {
    return 'Échec de la restauration de la dépense : $error';
  }

  @override
  String errDeleteExpense(String error) {
    return 'Échec de la suppression de la dépense : $error';
  }

  @override
  String get labelReimbursableShort => 'Remboursable';

  @override
  String get tooltipEditExpense => 'Modifier la Dépense';

  @override
  String get tooltipDeleteExpense => 'Supprimer la Dépense';

  @override
  String errPickFile(String error) {
    return 'Échec de la sélection du fichier : $error';
  }

  @override
  String get navViewExpenses => 'Voir les Dépenses';

  @override
  String get errAmountPositive => 'Le montant doit être positif';

  @override
  String get errDateFuture => 'La date ne peut pas être dans le futur';

  @override
  String get errDatePast => 'La date est trop ancienne';

  @override
  String get msgExpenseUpdated => 'Dépense mise à jour avec succès';

  @override
  String errUpdateExpense(String error) {
    return 'Échec de la mise à jour de la dépense : $error';
  }

  @override
  String get titleEditExpense => 'Modifier la Dépense';

  @override
  String get tooltipClose => 'Fermer';

  @override
  String get btnUpdateExpense => 'Mettre à jour la Dépense';

  @override
  String get btnClose => 'Fermer';

  @override
  String msgErrorWithParam(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String get btnAddExpense => 'Ajouter une Dépense';

  @override
  String get btnEdit => 'Modifier';

  @override
  String get labelEdit => 'Modifier';

  @override
  String get labelDelete => 'Supprimer';

  @override
  String get msgExpenseDeleted => 'Dépense supprimée';

  @override
  String get errAmountRequired => 'Veuillez entrer un montant';

  @override
  String get errInvalidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get errCategoryRequired => 'Veuillez sélectionner une catégorie';

  @override
  String get errDescriptionRequired => 'Veuillez entrer une description';

  @override
  String get labelAmount => 'Montant';

  @override
  String get labelCategory => 'Catégorie';

  @override
  String get labelDate => 'Date';

  @override
  String get labelDescription => 'Description';

  @override
  String get labelReimbursable => 'Remboursable';

  @override
  String get labelReimbursableExpense => 'Dépense remboursable';

  @override
  String get labelReimbursableHint => 'Peut être récupéré auprès de l\'entreprise';

  @override
  String get labelReceipt => 'Reçu';

  @override
  String get msgReceiptAttached => 'Reçu joint';

  @override
  String get labelRemoveReceipt => 'Supprimer le reçu';

  @override
  String get labelAttachReceipt => 'Joindre un reçu';

  @override
  String get btnReset => 'Réinitialiser';

  @override
  String get msgAddingExpense => 'Ajout en cours...';

  @override
  String get hintSelectCategory => 'Sélectionner Catégorie';

  @override
  String get hintDescription => 'C\'était pour quoi ?';

  @override
  String semanticSelectDate(String date) {
    return 'Sélectionnez la date. Actuelle : $date';
  }

  @override
  String get currency => 'DZD';

  @override
  String get filterReimbursable => 'Remboursable';

  @override
  String get filterNonReimbursable => 'Non-Remboursable';

  @override
  String get semanticFilter => 'Filtrer la liste';

  @override
  String get semanticAllCategories => 'Toutes les catégories';

  @override
  String get filterAllCategories => 'Toutes les catégories';

  @override
  String get msgAccountPending => 'Votre compte est en attente d\'approbation';

  @override
  String get labelEmail => 'Email';

  @override
  String get hintEmail => 'email@exemple.com';

  @override
  String get errEnterEmail => 'Veuillez entrer votre email';

  @override
  String get errInvalidEmail => 'Veuillez entrer un email valide';

  @override
  String get labelPassword => 'Mot de passe';

  @override
  String get hintPassword => 'Entrez votre mot de passe';

  @override
  String get errEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get btnSignIn => 'Se connecter';

  @override
  String get msgNoAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get btnRegisterManager => 'S\'inscrire comme Gestionnaire';

  @override
  String get btnContinueOffline => 'Continuer hors ligne';

  @override
  String get accountDetails => 'Détails du compte';

  @override
  String get exportReports => 'Exporter les rapports';

  @override
  String get appearance => 'Apparence';

  @override
  String get language => 'Langue';

  @override
  String get notifications => 'Notifications';

  @override
  String get security => 'Sécurité';

  @override
  String get backupRestore => 'Sauvegarde et Restauration';

  @override
  String get manageAccountPreferences => 'Gérer vos préférences de compte';

  @override
  String get viewAndManagePersonalInfo => 'Consultez et gérez vos informations personnelles';

  @override
  String memberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get errGeneric => 'Une erreur est survenue';

  @override
  String get msgCategoryUpdated => 'Profil mis à jour';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get fullName => 'Nom complet';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get location => 'Localisation';

  @override
  String get downloadExpenseData => 'Téléchargez vos données de dépenses au format CSV ou PDF';

  @override
  String get filterOptions => 'Options de filtrage';

  @override
  String get dateRange => 'Plage de dates';

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
  String get customizeAppLook => 'Personnalisez l\'apparence de l\'application sur votre appareil';

  @override
  String get themeMode => 'Mode thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

  @override
  String get selectPreferredLanguage => 'Sélectionnez votre langue préférée';

  @override
  String get hintSearchCategories => 'Rechercher...';

  @override
  String get manageNotifications => 'Gérez la façon dont vous recevez les notifications';

  @override
  String get notificationChannels => 'Canaux de notification';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get receivePush => 'Recevoir des notifications sur votre appareil';

  @override
  String get emailNotifications => 'Notifications par email';

  @override
  String get receiveEmail => 'Recevoir des mises à jour par email';

  @override
  String get notificationTypes => 'Types de notifications';

  @override
  String get newExpenseAdded => 'Nouvelle dépense ajoutée';

  @override
  String get notifyNewExpense => 'Être notifié lorsqu\'une nouvelle dépense est enregistrée';

  @override
  String get budgetUpdates => 'Mises à jour du budget';

  @override
  String get notifyBudgetUpdates => 'Être notifié des changements d\'état du budget';

  @override
  String get budgetLimitWarnings => 'Avertissements de limite de budget';

  @override
  String get notifyBudgetLimit => 'Alerte en cas d\'approche ou de dépassement des limites budgétaires';

  @override
  String get weeklySummary => 'Résumé hebdomadaire';

  @override
  String get notifyWeeklySummary => 'Recevoir des rapports hebdomadaires de synthèse des dépenses';

  @override
  String get monthlyReports => 'Rapports mensuels';

  @override
  String get notifyMonthlyReports => 'Obtenir des rapports financiers mensuels détaillés';

  @override
  String get quietHours => 'Heures de silence';

  @override
  String get enableQuietHours => 'Activer les heures de silence';

  @override
  String get muteNotifications => 'Désactiver les notifications pendant les heures spécifiées';

  @override
  String get from => 'De';

  @override
  String get to => 'À';

  @override
  String get manageSecurity => 'Gérez vos paramètres de sécurité et de confidentialité';

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
  String get useAuthenticatorApp => 'Utiliser une application d\'authentification pour plus de sécurité';

  @override
  String get setUp2fa => 'Configurer la 2FA';

  @override
  String get activeSessions => 'Sessions actives';

  @override
  String get signOutOtherSessions => 'Déconnecter toutes les autres sessions';

  @override
  String get deleteAllData => 'Supprimer toutes les données';

  @override
  String get deleteAllDataDesc => 'Supprimer définitivement toutes vos données de dépenses. Cette action est irréversible.';

  @override
  String get active => 'Actif';

  @override
  String get reimbursements => 'Remboursements';

  @override
  String get exportExcel => 'Exporter Excel';

  @override
  String get labelEmployee => 'Employé';

  @override
  String get labelApprovedAmount => 'Montant approuvé';

  @override
  String get labelPaymentDate => 'Date de paiement';

  @override
  String get statusPaid => 'Payé';

  @override
  String get statusUnpaid => 'Non payé';

  @override
  String get labelAddNewEmployee => 'Ajouter un nouvel employé';

  @override
  String get labelFillEmployeeDetails => 'Remplissez les détails de l\'employé ci-dessous';

  @override
  String get labelRole => 'Rôle';

  @override
  String get hintRole => 'Ingénieur logiciel';

  @override
  String get errEmployeeNameRequired => 'Veuillez entrer le nom de l\'employé';

  @override
  String get errPhoneRequired => 'Veuillez entrer le numéro de téléphone';

  @override
  String get errRoleRequired => 'Veuillez entrer le rôle';

  @override
  String get labelHireDate => 'Date d\'embauche';

  @override
  String get labelStatusSuspended => 'Suspendu';

  @override
  String get deptEngineering => 'Ingénierie';

  @override
  String get deptMarketing => 'Marketing';

  @override
  String get deptSales => 'Ventes';

  @override
  String get deptProduct => 'Produit';

  @override
  String get deptDesign => 'Design';

  @override
  String get deptHumanResources => 'Ressources humaines';

  @override
  String get deptFinance => 'Finance';

  @override
  String get btnBackToLogin => 'Retour à la connexion';

  @override
  String get titleRegisterManager => 'Enregistrer l\'organisation';

  @override
  String get subtitleRegisterManager => 'Créez un nouveau compte d\'organisation pour votre équipe';

  @override
  String get labelOrganizationName => 'Nom de l\'organisation';

  @override
  String get hintOrganizationName => 'Acme Corp';

  @override
  String get errEnterOrganizationName => 'Veuillez entrer le nom de l\'organisation';

  @override
  String get errOrganizationNameLength => 'Le nom doit comporter au moins 3 caractères';

  @override
  String get labelFullName => 'Nom complet';

  @override
  String get hintFullName => 'Jean Dupont';

  @override
  String get errEnterFullName => 'Veuillez entrer votre nom complet';

  @override
  String get hintCreatePassword => 'Créez un mot de passe sécurisé';

  @override
  String get errPasswordLength => 'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get labelConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get hintConfirmPassword => 'Répétez votre mot de passe';

  @override
  String get errConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get errPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get btnCreateOrganization => 'Créer l\'organisation';

  @override
  String get titleRegistrationSubmitted => 'Inscription soumise';

  @override
  String msgRegistrationSubmitted(String name) {
    return 'Votre demande pour $name a été soumise et est en attente d\'approbation par l\'administrateur.';
  }

  @override
  String get titleWhatHappensNext => 'Que se passe-t-il ensuite ?';

  @override
  String get stepReviewRequest => 'L\'administrateur examine votre demande';

  @override
  String get stepAccountActivation => 'Le compte est activé après approbation';

  @override
  String get stepLogin => 'Vous pourrez ensuite vous connecter et commencer la gestion';

  @override
  String get errUserProfileNotFound => 'Profil utilisateur non trouvé';

  @override
  String get errNoOrganization => 'Aucune organisation associée à ce compte';

  @override
  String msgAddEmployeeSuccess(String name) {
    return 'L\'employé $name a été ajouté avec succès';
  }

  @override
  String errAddEmployee(String error) {
    return 'Échec de l\'ajout de l\'employé : $error';
  }

  @override
  String msgRemoveEmployeeConfirm(String name) {
    return 'Êtes-vous sûr de vouloir retirer $name de l\'équipe ?';
  }

  @override
  String get actionRemove => 'Supprimer';

  @override
  String msgRemoveEmployeeSuccess(String name) {
    return 'L\'employé $name a été retiré avec succès';
  }

  @override
  String errRemoveEmployee(String error) {
    return 'Échec du retrait de l\'employé : $error';
  }

  @override
  String get statusDeactivated => 'Désactivé';

  @override
  String get statusActivated => 'Activé';

  @override
  String msgEmployeeStatusChanged(String name, String status) {
    return 'Le statut de l\'employé $name a été changé en $status';
  }

  @override
  String errUpdateStatus(String error) {
    return 'Échec de la mise à jour du statut : $error';
  }

  @override
  String get titleTeamManagement => 'Gestion de l\'équipe';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get titleErrorLoadingEmployees => 'Erreur lors du chargement des employés';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get titleNoEmployees => 'Pas encore d\'employés';

  @override
  String get msgNoEmployees => 'Vous n\'avez pas encore ajouté d\'employés à votre équipe.';

  @override
  String get btnAddFirstEmployee => 'Ajouter votre premier employé';

  @override
  String get titleOrganizationManagement => 'Gestion des organisations';

  @override
  String get tabPending => 'En attente';

  @override
  String get tabApproved => 'Approuvé';

  @override
  String get tabRejected => 'Rejeté';

  @override
  String msgOrgApproved(String name) {
    return 'L\'organisation $name a été approuvée';
  }

  @override
  String errApproveOrg(String error) {
    return 'Échec de l\'approbation de l\'organisation : $error';
  }

  @override
  String msgOrgRejected(String name) {
    return 'L\'organisation $name a été rejetée';
  }

  @override
  String errRejectOrg(String error) {
    return 'Échec du rejet de l\'organisation : $error';
  }

  @override
  String dialogTitleRejectOrg(String name) {
    return 'Rejeter $name ?';
  }

  @override
  String get labelRejectReason => 'Veuillez fournir une raison pour le rejet :';

  @override
  String get hintRejectReason => 'Raison du rejet...';

  @override
  String get actionReject => 'Rejeter';

  @override
  String get errLoadOrgs => 'Erreur lors du chargement des organisations';

  @override
  String get msgNoOrgs => 'Aucune organisation trouvée';

  @override
  String get titleExpenseDetails => 'Détails de la dépense';

  @override
  String get btnApprove => 'Approuver';

  @override
  String get btnReject => 'Rejeter';

  @override
  String get btnAddComment => 'Ajouter un commentaire';

  @override
  String get labelComments => 'Commentaires';

  @override
  String get labelViewReceipt => 'Voir le reçu';

  @override
  String get titleAddComment => 'Ajouter un commentaire';

  @override
  String get labelComment => 'Commentaire';

  @override
  String get hintComment => 'Entrez votre commentaire ici...';

  @override
  String get errCommentRequired => 'Veuillez entrer un commentaire';

  @override
  String get errCommentLength => 'Le commentaire doit comporter au moins 3 caractères';

  @override
  String get btnSubmit => 'Soumettre';

  @override
  String get labelTotal => 'Total';

  @override
  String get titleNoPendingApprovals => 'Aucune approbation en attente';

  @override
  String get msgAllExpensesProcessed => 'Toutes les dépenses ont été traitées';

  @override
  String get tooltipViewDetails => 'Voir les détails';

  @override
  String get tooltipApprove => 'Approuver';

  @override
  String get tooltipReject => 'Rejeter';

  @override
  String get tooltipComment => 'Commenter';

  @override
  String get titleRejectExpense => 'Rejeter la dépense';

  @override
  String get labelRejectionReason => 'Raison du rejet';

  @override
  String get hintRejectionReason => 'Entrez la raison du rejet';

  @override
  String get labelViewDetails => 'Voir les détails';

  @override
  String get labelSuspend => 'Suspendre';

  @override
  String get labelActivate => 'Activer';

  @override
  String get labelRemove => 'Supprimer';

  @override
  String get labelBy => 'par';

  @override
  String get labelStatusActive => 'Actif';

  @override
  String get msgExportExcel => 'Exportation vers Excel...';

  @override
  String get msgExportPdf => 'Exportation vers PDF...';

  @override
  String get labelBudget => 'Budget';

  @override
  String get labelDescCreateAccount => 'Créer un nouveau compte pour un membre de l\'équipe';

  @override
  String get labelTemporaryPassword => 'Mot de passe temporaire';

  @override
  String get hintTemporaryPassword => 'Créer un mot de passe temporaire';

  @override
  String get msgPasswordChangeHint => 'L\'employé pourra changer ce mot de passe après sa première connexion.';

  @override
  String get labelDeactivate => 'Désactiver';

  @override
  String get statusInactive => 'Inactif';

  @override
  String get labelUnknown => 'Inconnu';

  @override
  String get ownerDashboard => 'Tableau de Bord Propriétaire';

  @override
  String get subtitleOwnerDashboard => 'Gérez les organisations, approuvez les gestionnaires et surveillez l\'activité de la plateforme';

  @override
  String get kpiTotalCompanies => 'Total des Entreprises';

  @override
  String get kpiTotalManagers => 'Total des Gestionnaires';

  @override
  String get kpiPendingApprovalsSubtitle => 'Gestionnaires en attente d\'approbation';

  @override
  String get kpiMonthlyGrowth => 'Croissance Mensuelle';

  @override
  String get kpiMonthlyGrowthSubtitle => 'Croissance à l\'échelle de la plateforme';

  @override
  String get headerPendingManagerRequests => 'Demandes de Gestionnaires en Attente';

  @override
  String get headerActiveManagers => 'Gestionnaires Actifs';

  @override
  String get headerRecentActivity => 'Activité Récente';

  @override
  String get msgNoRecentActivity => 'Aucune activité récente trouvée';

  @override
  String get msgManagerApproved => 'Gestionnaire approuvé avec succès';

  @override
  String get msgManagerRejected => 'Gestionnaire rejeté';

  @override
  String get msgManagerSuspended => 'Compte du gestionnaire suspendu';

  @override
  String get dialogTitleConfirmDelete => 'Confirmer la Suppression';

  @override
  String get dialogDescDeleteManager => 'Êtes-vous sûr de vouloir supprimer ce gestionnaire ? Cette action est irréversible.';

  @override
  String get msgManagerDeleted => 'Compte du gestionnaire supprimé';

  @override
  String get msgManagerProfileComingSoon => 'La vue du profil du gestionnaire sera bientôt disponible';

  @override
  String get dialogTitleRejectManager => 'Rejeter le Gestionnaire';

  @override
  String get dialogLabelReasonRejection => 'Raison du Rejet';

  @override
  String get dialogHintEnterReason => 'Entrez la raison...';

  @override
  String get dialogActionReject => 'Rejeter';

  @override
  String get dialogTitleSuspendManager => 'Suspendre le Gestionnaire';

  @override
  String get dialogLabelReasonSuspension => 'Raison de la Suspension';

  @override
  String get dialogActionSuspend => 'Suspendre';

  @override
  String get titleRemoveEmployee => 'Supprimer l\'employé';

  @override
  String get msgExpenseAdded => 'Dépense ajoutée avec succès';

  @override
  String get navBudgets => 'Budgets';

  @override
  String get navManagerDashboard => 'Tableau de Bord Gestionnaire';

  @override
  String get titleViewExpenses => 'Voir les Dépenses';

  @override
  String get subtitleViewExpenses => 'Parcourez et gérez vos dépenses';

  @override
  String get hintSearchExpenses => 'Rechercher des dépenses...';

  @override
  String get searchSemanticLabel => 'Rechercher';

  @override
  String get clearSearchSemanticLabel => 'Effacer la recherche';

  @override
  String get dashboardSubtitle => 'Suivez vos dépenses et gérez vos finances';

  @override
  String get numberofCategories => 'Catégories';

  @override
  String get dailyAvgSpending => 'Moyenne Quotidienne';

  @override
  String get msgCategoryAdded => 'Catégorie ajoutée avec succès';

  @override
  String msgAddCategoryFailed(String error) {
    return 'Échec de l\'ajout de la catégorie : $error';
  }

  @override
  String get msgCategoryDeleted => 'Catégorie supprimée avec succès';

  @override
  String msgDeleteCategoryFailed(String error) {
    return 'Échec de la suppression de la catégorie : $error';
  }
}
