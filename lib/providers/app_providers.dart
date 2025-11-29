import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  return ExpenseService(expenseRepository, categoryRepository, database);
});
