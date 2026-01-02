import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/database/i_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/i_category_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/i_expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/i_expense_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/budget_validation_service.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/receipt_upload_service.dart';
import 'package:expense_tracking_desktop_app/services/backup_service.dart';
import 'package:expense_tracking_desktop_app/services/connectivity_service.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import 'package:expense_tracking_desktop_app/services/i_backup_service.dart';
import 'package:expense_tracking_desktop_app/services/logger_service.dart';
import 'package:expense_tracking_desktop_app/services/error_reporting_service.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import 'package:expense_tracking_desktop_app/services/sync_service.dart';

/// Logger service provider - centralized logging
final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService.instance;
});

/// Error reporting service provider - tracks and reports errors
final errorReportingServiceProvider = Provider<ErrorReportingService>((ref) {
  throw UnimplementedError('ErrorReportingService provider must be overridden');
});

/// Connectivity service provider - tracks database/filesystem connection state
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  throw UnimplementedError('ConnectivityService provider must be overridden');
});

/// Database provider - the single source of truth
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});

/// Database interface provider - enables DIP compliance
final databaseInterfaceProvider = Provider<IDatabase>((ref) {
  return ref.watch(databaseProvider); // AppDatabase implements IDatabase
});

/// Budget repository provider - returns interface type for LSP compliance
final budgetRepositoryProvider = Provider<IBudgetRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BudgetRepository(database);
});

/// Category repository provider - returns interface type for LSP compliance
final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryRepository(database);
});

/// Expense repository provider - returns interface type for LSP compliance
final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ExpenseRepository(database);
});

/// Expense service provider
final expenseServiceProvider = Provider<IExpenseService>((ref) {
  final database = ref.watch(databaseInterfaceProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  // ExpenseService only needs reader and budget manager interfaces (ISP)
  return ExpenseService(
    expenseRepository,
    categoryRepository, // ICategoryRepository implements both interfaces
    categoryRepository, // Pass same instance for both reader and budget manager
    database,
  );
});

/// Budget validation service provider
final budgetValidationServiceProvider = Provider<BudgetValidationService>((ref) {
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return BudgetValidationService(categoryRepository);
});

/// Supabase service provider - singleton instance
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Receipt upload service provider
final receiptUploadServiceProvider = Provider<ReceiptUploadService>((ref) {
  final database = ref.watch(databaseProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return ReceiptUploadService(database, supabaseService);
});

/// Backup service provider - handles database backup and restore operations
final backupServiceProvider = Provider<IBackupService>((ref) {
  final logger = ref.watch(loggerServiceProvider);
  return BackupService(logger: logger);
});

/// Sync service provider - handles offline-first synchronization
final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final logger = LoggerService.instance;
  return SyncService(
    database: database,
    supabaseService: supabaseService,
    logger: logger,
  );
});

/// Sync status stream provider - exposes sync status as a stream
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.statusStream;
});

/// Pending sync count provider - exposes pending item count
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.pendingCountStream;
});

/// Auth state provider - exposes current user authentication state
final authStateProvider = StreamProvider<bool>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.client.auth.onAuthStateChange.map(
    (event) => event.session != null,
  );
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return supabaseService.currentUser;
});
