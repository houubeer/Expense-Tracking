import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/features/home/screens/home_screen.dart';
import 'package:expense_tracking_desktop_app/features/expenses/screens/add_expense_screen.dart';
import 'package:expense_tracking_desktop_app/features/expenses/screens/expenses_list_screen.dart';
import 'package:expense_tracking_desktop_app/features/budget/screens/budget_setting_screen.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/sidebar.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';
import 'package:expense_tracking_desktop_app/widgets/connection_status_banner.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Creates the app router
GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    errorBuilder: (context, state) => const _ErrorScreen(),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: Column(
              children: [
                const ConnectionStatusBanner(),
                Expanded(
                  child: Row(
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
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.viewExpenses,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ExpensesListScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              GoRoute(
                path: 'add',
                pageBuilder: (context, state) {
                  final categoryId = state.uri.queryParameters['categoryId'];
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: AddExpenseScreen(
                      preSelectedCategoryId:
                          categoryId != null ? int.tryParse(categoryId) : null,
                    ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.budgets,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BudgetSettingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
