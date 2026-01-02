import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/organization.dart';

/// Auth state class to hold authentication info
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final bool isPendingApproval;
  final UserProfile? userProfile;
  final Organization? organization;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.isPendingApproval = false,
    this.userProfile,
    this.organization,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    bool? isPendingApproval,
    UserProfile? userProfile,
    Organization? organization,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      userProfile: userProfile ?? this.userProfile,
      organization: organization ?? this.organization,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Check if user can access the app
  bool get canAccess => isAuthenticated && !isPendingApproval;

  /// Get redirect route based on user role
  String getRedirectRoute() {
    if (!isAuthenticated) return '/auth/login';
    if (isPendingApproval) return '/auth/pending';

    switch (userProfile?.role) {
      case UserRole.owner:
        return '/owner';
      case UserRole.manager:
        return '/manager';
      case UserRole.employee:
        return '/';
      default:
        return '/';
    }
  }
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      // Check if remember me is enabled
      final box = await Hive.openBox<dynamic>('auth_preferences');
      final rememberMe = box.get('remember_me') as bool? ?? true;

      final supabaseService = _ref.read(supabaseServiceProvider);

      if (supabaseService.isAuthenticated && rememberMe) {
        await _loadUserProfile();
      } else if (!rememberMe) {
        // If remember me is off, sign out
        try {
          await supabaseService.signOut();
        } catch (_) {}
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      final profileData = await supabaseService.getCurrentUserProfile();

      if (profileData != null) {
        final userProfile = profileData;

        // Check if user is pending approval
        final isPending =
            !userProfile.isActive && userProfile.role != UserRole.owner;

        // Load organization if user has one
        Organization? organization;
        if (userProfile.organizationId != null) {
          try {
            final orgData = await supabaseService.getOrganization(
              userProfile.organizationId!,
            );
            if (orgData != null) {
              organization = orgData;
            }
          } catch (_) {
            // Org load failed, continue without it
          }
        }

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          isPendingApproval: isPending,
          userProfile: userProfile,
          organization: organization,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Check connectivity first
    final connectivityService = _ref.read(connectivityServiceProvider);
    if (!connectivityService.isConnected) {
      state = state.copyWith(
        errorMessage: 'No internet connection. You must be online to sign in.',
      );
      throw Exception('No internet connection. You must be online to sign in.');
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      final result =
          await supabaseService.signIn(email: email, password: password);

      if (result['success'] != true) {
        final message = result['message'] as String? ?? 'Login failed';
        state = state.copyWith(isLoading: false, errorMessage: message);
        throw Exception(message);
      }

      await _loadUserProfile();

      // Initialize sync service after login (only if user has access)
      if (state.canAccess) {
        final syncService = _ref.read(syncServiceProvider);
        await syncService.initialize();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    await _loadUserProfile();
  }

  /// Clear any stored session data
  Future<void> clearSession() async {
    try {
      final box = await Hive.openBox<dynamic>('auth_preferences');
      await box.delete('remembered_email');
      await box.put('remember_me', false);
    } catch (_) {}
  }
}

/// Provider for auth state
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

/// Provider to check if user is owner
final isOwnerProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userProfile?.role == UserRole.owner;
});

/// Provider to check if user is manager
final isManagerProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userProfile?.role == UserRole.manager;
});

/// Provider to check if user is employee
final isEmployeeProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userProfile?.role == UserRole.employee;
});

/// Provider to check if user's account is active
final isActiveProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userProfile?.isActive ?? false;
});
