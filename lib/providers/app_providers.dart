import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';

/// Database provider - the single source of truth
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});

/// Budget repository provider
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BudgetRepository(database);
});

/// Category repository provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryRepository(database);
});

/// Expense repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ExpenseRepository(database);
});

/// Expense service provider
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final database = ref.watch(databaseProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return ExpenseService(expenseRepository, categoryRepository, database);
});
