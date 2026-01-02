import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import 'package:expense_tracking_desktop_app/features/auth/models/user_profile.dart';

/// Provider to fetch and update the current user's account details.
class AccountNotifier extends AsyncNotifier<UserProfile?> {
  final _supabase = SupabaseService();

  @override
  Future<UserProfile?> build() async {
    final uid = _supabase.currentUser?.id;
    if (uid == null) {
      // Not authenticated
      return null;
    }

    final profile = await _supabase.getUserProfile(uid);
    return profile;
  }

  /// Refresh the profile from backend
  Future<void> refresh() async {
    state = await AsyncValue.guard(() async => build());
  }

  /// Update the user's full name
  Future<bool> updateFullName(String fullName) async {
    final current = state.value;
    if (current == null) return false;

    final updated = current.copyWith(
      fullName: fullName,
      updatedAt: DateTime.now(),
    );

    final ok = await _supabase.updateUserProfile(updated);
    if (ok) state = AsyncValue.data(updated);
    return ok;
  }

  /// Update a free-form 'location' value inside the settings JSON column
  Future<bool> updateLocation(String location) async {
    final current = state.value;
    if (current == null) return false;

  final newSettings = Map<String, dynamic>.from(current.settings);
    newSettings['location'] = location;

    final updated = current.copyWith(
      settings: newSettings,
      updatedAt: DateTime.now(),
    );

    final ok = await _supabase.updateUserProfile(updated);
    if (ok) state = AsyncValue.data(updated);
    return ok;
  }
}

final accountProvider = AsyncNotifierProvider<AccountNotifier, UserProfile?>(() {
  return AccountNotifier();
});
