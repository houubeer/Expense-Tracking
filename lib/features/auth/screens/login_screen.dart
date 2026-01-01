import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracking_desktop_app/constants/colors.dart';
import 'package:expense_tracking_desktop_app/constants/spacing.dart';
import 'package:expense_tracking_desktop_app/constants/text_styles.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/auth/widgets/auth_text_field.dart';
import 'package:expense_tracking_desktop_app/features/auth/widgets/auth_button.dart';

/// Login screen for user authentication
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      final result = await supabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Check user role and navigate accordingly
      final userProfile = result['user_profile'] as Map<String, dynamic>?;
      if (userProfile != null) {
        final role = userProfile['role'] as String?;
        final isActive = userProfile['is_active'] as bool? ?? false;

        if (!isActive) {
          setState(() {
            _errorMessage =
                'Your account is pending approval. Please wait for the organization owner to approve your access.';
            _isLoading = false;
          });
          return;
        }

        // Navigate based on role
        switch (role) {
          case 'owner':
            context.go('/owner');
            break;
          case 'manager':
            context.go('/manager');
            break;
          case 'employee':
          default:
            context.go('/');
            break;
        }
      } else {
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and title
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Expense Tracker',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to your account',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.red, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Email field
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Login button
                  AuthButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/auth/register'),
                        child: Text(
                          'Register as Manager',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Continue offline link
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: Text(
                      'Continue Offline',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
