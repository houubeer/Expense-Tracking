import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/features/home/screens/home_screen.dart';
import 'package:expense_tracking_desktop_app/features/expenses/screens/add_expense_screen.dart';
import 'package:expense_tracking_desktop_app/features/expenses/screens/expenses_list_screen.dart';
import 'package:expense_tracking_desktop_app/features/budget/screens/budget_setting_screen.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/screens/manager_dashboard_screen.dart';
import 'package:expense_tracking_desktop_app/features/manager_dashboard/screens/employee_expenses_screen.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/screens/owner_dashboard_screen.dart';
import 'package:expense_tracking_desktop_app/features/settings/screens/settings_screen.dart';
import 'package:expense_tracking_desktop_app/features/auth/screens/login_screen.dart';
import 'package:expense_tracking_desktop_app/features/auth/screens/manager_signup_screen.dart';
import 'package:expense_tracking_desktop_app/features/auth/screens/employee_management_screen.dart';
import 'package:expense_tracking_desktop_app/features/auth/screens/forgot_password_screen.dart';
import 'package:expense_tracking_desktop_app/features/auth/screens/reset_password_screen.dart';
import 'package:expense_tracking_desktop_app/features/auth/screens/pending_approval_screen.dart';
import 'package:expense_tracking_desktop_app/features/shared/widgets/common/sidebar.dart';
import 'package:expense_tracking_desktop_app/constants/app_routes.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/widgets/buttons.dart';
import 'package:expense_tracking_desktop_app/widgets/connection_status_banner.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Expose router through Riverpod while keeping a direct factory for non-Riverpod usage.
final routerProvider = Provider<GoRouter>((ref) => _buildRouter());

/// Check if user is authenticated and get their role for redirect
Future<String?> _getAuthRedirect() async {
  try {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // Fetch user profile to determine role
    final profile = await supabase
        .from('user_profiles')
        .select('role, status, organization_id')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return null;

    final role = profile['role'] as String?;
    final status = profile['status'] as String?;

    // If not active and not owner, they're pending approval
    // status is 'active' or null (for backwards compatibility) means active
    if (status != 'active' && status != null && role != 'owner') {
      return AppRoutes.pendingApproval;
    }

    switch (role) {
      case 'owner':
        return AppRoutes.ownerDashboard;
      case 'manager':
        return AppRoutes.managerDashboard;
      case 'employee':
        return AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  } catch (e) {
    return null;
  }
}

/// Creates the app router
GoRouter createRouter() => _buildRouter();

GoRouter _buildRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.login,
    redirect: (context, state) async {
      // Only redirect on login page - check if already authenticated
      if (state.uri.path == AppRoutes.login) {
        final redirect = await _getAuthRedirect();
        if (redirect != null) {
          return redirect;
        }
      }

      return null;
    },
    errorBuilder: (context, state) => const _ErrorScreen(),
    routes: [
      // Auth routes (no shell/sidebar)
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ManagerSignupScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final email = state.uri.queryParameters['email'];
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResetPasswordScreen(token: token, email: email),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.pendingApproval,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PendingApprovalScreen(
              userEmail: extra?['email'] as String?,
              organizationName: extra?['organizationName'] as String?,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      // Main app routes with shell/sidebar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Remove sidebar for owner dashboard
          final isOwnerDashboard = state.uri.path == AppRoutes.ownerDashboard;
          return Scaffold(
            body: Column(
              children: [
                const ConnectionStatusBanner(),
                Expanded(
                  child: isOwnerDashboard
                      ? child
                      : Row(
                          children: [
                            Sidebar(
                              currentPath: state.uri.path,
                              onDestinationSelected: (path) {
                                // Use push for settings to show as modal overlay
                                // so the dashboard remains visible behind it
                                if (path == AppRoutes.settings) {
                                  context.push(path);
                                } else {
                                  context.go(path);
                                }
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
          GoRoute(
            path: AppRoutes.managerDashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: ManagerDashboardScreen(
                onNavigate: (path) => context.go(path),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              GoRoute(
                path: 'expenses',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: EmployeeExpensesScreen(
                    onNavigate: (path) => context.go(path),
                  ),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
              GoRoute(
                path: 'employees',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const EmployeeManagementScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.ownerDashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const OwnerDashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false, // Allow seeing content behind
          barrierDismissible: true,
          barrierColor: Colors.transparent, // Transparent to show backdrop
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade in the backdrop and slide in the settings
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
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
