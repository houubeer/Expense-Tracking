import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import '../models/audit_log_model.dart';

class AuditLogRepository {
  final SupabaseService _supabaseService;

  AuditLogRepository(this._supabaseService);

  SupabaseClient get _client => _supabaseService.client;
  User? get _currentUser => _supabaseService.currentUser;

  Future<void> createAuditLog({
    required String organizationId,
    required String action,
    required String tableName,
    int? recordId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? description,
  }) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    final userProfile = await _client
        .from('user_profiles')
        .select('email, full_name')
        .eq('id', _currentUser!.id)
        .single();

    await _client.from('audit_logs').insert({
      'organization_id': organizationId,
      'user_id': _currentUser!.id,
      'user_email': userProfile['email'] as String,
      'user_name': userProfile['full_name'] as String,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
      'old_data': oldData,
      'new_data': newData,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<AuditLog>> getAuditLogs(String organizationId) async {
    final response = await _client
        .from('audit_logs')
        .select()
        .eq('organization_id', organizationId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AuditLog>> getRecentAuditLogs(String organizationId,
      {int limit = 10}) async {
    final response = await _client
        .from('audit_logs')
        .select()
        .eq('organization_id', organizationId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => AuditLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
