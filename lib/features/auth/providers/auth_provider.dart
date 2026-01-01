import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/providers/app_providers.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/organization.dart';

/// Auth state class to hold authentication info
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserProfile? userProfile;
  final Organization? organization;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userProfile,
    this.organization,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserProfile? userProfile,
    Organization? organization,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      organization: organization ?? this.organization,
      errorMessage: errorMessage ?? this.errorMessage,
    );
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
      final supabaseService = _ref.read(supabaseServiceProvider);
      if (supabaseService.isAuthenticated) {
        await _loadUserProfile();
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
        final userProfile = UserProfile.fromJson(profileData);

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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.signIn(email: email, password: password);
      await _loadUserProfile();

      // Initialize sync service after login
      final syncService = _ref.read(syncServiceProvider);
      await syncService.initialize();
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
