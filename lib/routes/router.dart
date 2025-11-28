import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/database/app_database.dart';
import 'package:expense_tracking_desktop_app/features/home/screens/home_screen.dart';
import 'package:expense_tracking_desktop_app/features/expenses/screens/add_expense_screen.dart';
import 'package:expense_tracking_desktop_app/features/expenses/screens/expenses_list_screen.dart';
import 'package:expense_tracking_desktop_app/features/budget/screens/budget_setting_screen.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/sidebar.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/budget_repository.dart';
import 'package:expense_tracking_desktop_app/features/budget/repositories/category_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/repositories/expense_repository.dart';
import 'package:expense_tracking_desktop_app/features/expenses/services/expense_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Creates the app router with the provided database instance
GoRouter createRouter(AppDatabase database) {
  // Initialize repositories
  final budgetRepository = BudgetRepository(database);
  final categoryRepository = CategoryRepository(database);
  final expenseRepository = ExpenseRepository(database);

  // Initialize services with database for transactions
  final expenseService = ExpenseService(
    expenseRepository,
    categoryRepository,
    database,
  );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const _ErrorScreen(),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  currentPath: state.uri.path,
                  onDestinationSelected: (path) {
                    context.go(path);
                  },
                ),
                Expanded(
                  child: child,
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.viewExpenses,
            builder: (context, state) => const ExpensesListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final categoryId = state.uri.queryParameters['categoryId'];
                  return AddExpenseScreen(
                    preSelectedCategoryId:
                        categoryId != null ? int.tryParse(categoryId) : null,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.budgets,
            builder: (context, state) => BudgetSettingScreen(
              categoryRepository: categoryRepository,
            ),
          ),
        ],
      ),
    ],
  );
}

/// Error screen shown when navigation fails or route is not found
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppColors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
