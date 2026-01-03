import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';

/// Provider that exposes and persists the user's notification settings.
///
/// Data shape:
/// {
///   'channels': {'push': bool, 'email': bool},
///   'types': {
///     'newExpenseAdded': bool,
///     'budgetUpdates': bool,
///     'budgetLimitWarnings': bool,
///     'weeklySummary': bool,
///     'monthlyReports': bool,
///   },
///   'quietHours': {'enabled': bool, 'from': String, 'to': String}
/// }
class NotificationsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  final _svc = SupabaseService();

  @override
  Future<Map<String, dynamic>> build() async {
    // Load existing settings from backend (user_profiles.settings.notifications)
    final settings = await _svc.getNotificationSettingsForCurrentUser();
    // Ensure defaults
    return _withDefaults(settings);
  }

  Map<String, dynamic> _withDefaults(Map<String, dynamic>? inSettings) {
    final defaultShape = {
      'channels': {'push': true, 'email': true},
      'types': {
        'newExpenseAdded': true,
        'budgetUpdates': true,
        'budgetLimitWarnings': true,
        'weeklySummary': true,
        'monthlyReports': true,
      },
      'quietHours': {'enabled': false, 'from': '22:00', 'to': '08:00'},
    };

    if (inSettings == null) return defaultShape;

    final channels = Map<String, dynamic>.from(
        (inSettings['channels'] as Map?)?.cast<String, dynamic>() ?? {});
    final types = Map<String, dynamic>.from(
        (inSettings['types'] as Map?)?.cast<String, dynamic>() ?? {});
    final quiet = Map<String, dynamic>.from(
        (inSettings['quietHours'] as Map?)?.cast<String, dynamic>() ?? {});

    return {
      'channels': {
        'push': channels['push'] ?? defaultShape['channels']!['push'],
        'email': channels['email'] ?? defaultShape['channels']!['email'],
      },
      'types': {
        'newExpenseAdded': types['newExpenseAdded'] ?? defaultShape['types']!['newExpenseAdded'],
        'budgetUpdates': types['budgetUpdates'] ?? defaultShape['types']!['budgetUpdates'],
        'budgetLimitWarnings': types['budgetLimitWarnings'] ?? defaultShape['types']!['budgetLimitWarnings'],
        'weeklySummary': types['weeklySummary'] ?? defaultShape['types']!['weeklySummary'],
        'monthlyReports': types['monthlyReports'] ?? defaultShape['types']!['monthlyReports'],
      },
      'quietHours': {
        'enabled': quiet['enabled'] ?? defaultShape['quietHours']!['enabled'],
        'from': quiet['from'] ?? defaultShape['quietHours']!['from'],
        'to': quiet['to'] ?? defaultShape['quietHours']!['to'],
      },
    };
  }

  /// Update a top-level boolean in channels
  Future<void> setChannel(String key, bool value) async {
    final current = state.value ?? _withDefaults(null);
    final updated = Map<String, dynamic>.from(current);
    final channels = Map<String, dynamic>.from(updated['channels'] as Map);
    channels[key] = value;
    updated['channels'] = channels;
    state = AsyncValue.data(updated);
  }

  /// Update a notification type
  Future<void> setType(String key, bool value) async {
    final current = state.value ?? _withDefaults(null);
    final updated = Map<String, dynamic>.from(current);
    final types = Map<String, dynamic>.from(updated['types'] as Map);
    types[key] = value;
    updated['types'] = types;
    state = AsyncValue.data(updated);
  }

  /// Update quiet hours settings
  Future<void> setQuietHours({required bool enabled, String? from, String? to}) async {
    final current = state.value ?? _withDefaults(null);
    final updated = Map<String, dynamic>.from(current);
    final quiet = Map<String, dynamic>.from(updated['quietHours'] as Map);
    quiet['enabled'] = enabled;
    if (from != null) quiet['from'] = from;
    if (to != null) quiet['to'] = to;
    updated['quietHours'] = quiet;
    state = AsyncValue.data(updated);
  }

  /// Persist current settings to Supabase (user_profiles.settings.notifications)
  Future<bool> save() async {
    final current = state.value;
    if (current == null) return false;
    final ok = await _svc.updateNotificationSettingsForCurrentUser(current);
    return ok;
  }
}

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, Map<String, dynamic>>(() {
  return NotificationsNotifier();
},);
