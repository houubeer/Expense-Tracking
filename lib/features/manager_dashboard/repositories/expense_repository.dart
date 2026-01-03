import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:expense_tracking_desktop_app/services/supabase_service.dart';
import '../models/expense_model.dart';
import 'audit_log_repository.dart';

// Helper for parsing status string to ExpenseStatus
ExpenseStatus _parseStatus(String? statusStr) {
  if (statusStr == null) return ExpenseStatus.pending;
  return ExpenseStatus.values.firstWhere(
    (e) => e.name == statusStr,
    orElse: () => ExpenseStatus.pending,
  );
}

class ExpenseRepository {
  final SupabaseService _supabaseService;
  final AuditLogRepository _auditLogRepository;

  ExpenseRepository(this._supabaseService, this._auditLogRepository);

  SupabaseClient get _client => _supabaseService.client;
  User? get _currentUser => _supabaseService.currentUser;

  Future<String> _getCurrentOrgId() async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }
    final profile = await _client
        .from('user_profiles')
        .select('organization_id')
        .eq('id', _currentUser!.id)
        .single();
    final orgId = profile['organization_id'] as String?;
    if (orgId == null) {
      throw Exception('User has no organization');
    }
    return orgId;
  }

  Future<List<ManagerExpense>> _enrichWithProfiles(List<dynamic> data) async {
    final expenses = data.cast<Map<String, dynamic>>();
    
    final userIds = expenses
        .map((e) => e['created_by'] as String?)
        .where((id) => id != null)
        .toSet()
        .toList();

    final Map<String, Map<String, dynamic>> userProfilesMap = {};
    if (userIds.isNotEmpty) {
      final profilesResponse = await _client
          .from('user_profiles')
          .select('id, full_name, email')
          .filter('id', 'in', userIds);
      
      for (final profile in profilesResponse as List) {
        final id = profile['id'] as String;
        userProfilesMap[id] = profile as Map<String, dynamic>;
      }
    }

    return expenses.map((expense) {
      final userId = expense['created_by'] as String?;
      final userProfile = userProfilesMap[userId];

      return ManagerExpense.fromJson({
        ...expense,
        'employeeName': userProfile?['full_name'] ?? 'Unknown',
      });
    }).toList();
  }

  Future<List<ManagerExpense>> getAllExpenses() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .order('date', ascending: false);

    return _enrichWithProfiles(response as List);
  }

  Future<List<ManagerExpense>> getPendingExpenses() async {
    final orgId = await _getCurrentOrgId();

    // The 'status' column does not exist in the DB.
    // We fetch all non-reimbursed expenses and treat them as 'pending' for now.
    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .order('date', ascending: false);
    
    final enriched = await _enrichWithProfiles(response as List);
    // Filter in-memory: if reimbursed_at is null, assume pending/approved/rejected bucket.
    // Since we can't distinguish, we return all active non-reimbursed items.
    return enriched.where((e) => e.reimbursedAt == null).toList();
  }

  Future<List<ManagerExpense>> getExpensesByEmployee(String employeeId) async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .eq('created_by', employeeId)
        .order('date', ascending: false);

    return _enrichWithProfiles(response as List);
  }

  Future<List<ManagerExpense>> getExpensesByStatus(ExpenseStatus status) async {
    final orgId = await _getCurrentOrgId();

    // Fetch all and filter in Dart
    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .order('date', ascending: false);

    final allExpenses = await _enrichWithProfiles(response as List);
    
    // Manual mapping/filtering
    return allExpenses.where((e) {
      if (status == ExpenseStatus.approved) {
        // Assume anything reimbursed is approved
        return e.reimbursedAt != null;
      } else if (status == ExpenseStatus.pending) {
        // Treat everything non-reimbursed as pending for now
        return e.reimbursedAt == null;
      } else if (status == ExpenseStatus.rejected) {
          return (e.notes ?? '').toLowerCase().contains('reject');
      }
      return false;
    }).toList();
  }

  Future<List<ManagerExpense>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .gte('date', start.toIso8601String().split('T')[0])
        .lte('date', end.toIso8601String().split('T')[0])
        .order('date', ascending: false);

    return _enrichWithProfiles(response as List);
  }

  Future<List<ManagerExpense>> getExpensesByCategory(String category) async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .ilike('description', '%$category%')
        .order('date', ascending: false);

    return _enrichWithProfiles(response as List);
  }

  Future<List<ManagerExpense>> getReimbursableExpenses() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select()
        .eq('organization_id', orgId)
        .eq('is_reimbursable', true)
        .order('date', ascending: false);

    return _enrichWithProfiles(response as List);
  }

  Future<double> getTotalExpensesAmount() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select('amount')
        .eq('organization_id', orgId);

    return (response as List).fold<double>(
      0.0,
      (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0),
    );
  }

  Future<Map<ExpenseStatus, int>> getExpenseCountByStatus() async {
    final orgId = await _getCurrentOrgId();

    // Select minimal fields to infer status
    final response = await _client
        .from('expenses')
        .select('reimbursed_at')
        .eq('organization_id', orgId);

    final counts = <ExpenseStatus, int>{};
    for (final status in ExpenseStatus.values) {
      counts[status] = 0;
    }

    for (final item in response as List) {
      final isReimbursed = item['reimbursed_at'] != null;
      if (isReimbursed) {
        counts[ExpenseStatus.approved] = (counts[ExpenseStatus.approved] ?? 0) + 1;
      } else {
        // Default to pending for all non-reimbursed
        counts[ExpenseStatus.pending] = (counts[ExpenseStatus.pending] ?? 0) + 1;
      }
    }

    return counts;
  }

  Future<List<String>> getAllCategories() async {
    final orgId = await _getCurrentOrgId();

    final response = await _client
        .from('expenses')
        .select('description')
        .eq('organization_id', orgId);

    // Using description as category proxy if category column missing/unused? 
    // Logic from previous code preserved.
    final categories = (response as List)
        .map((item) => item['description'] as String? ?? 'Other')
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  Future<List<ManagerExpense>> getCurrentMonthExpenses() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    return getExpensesByDateRange(startOfMonth, endOfMonth);
  }

  Future<void> approveExpense(String expenseId) async {
    final orgId = await _getCurrentOrgId();
    // Update logic to be implemented once schema is updated

    await _auditLogRepository.createAuditLog(
      organizationId: orgId,
      action: 'APPROVE_EXPENSE',
      tableName: 'expenses',
      recordId: int.parse(expenseId),
      oldData: {},
      newData: {'status': 'approved (simulated)'},
      description: 'Approved expense #$expenseId',
    );
  }

  Future<void> rejectExpense(String expenseId, String reason) async {
    final orgId = await _getCurrentOrgId();
    await _client
        .from('expenses')
        .update({
          'notes': reason,
        })
        .eq('id', int.parse(expenseId))
        .eq('organization_id', orgId);

    await _auditLogRepository.createAuditLog(
      organizationId: orgId,
      action: 'REJECT_EXPENSE',
      tableName: 'expenses',
      recordId: int.parse(expenseId),
      oldData: {},
      newData: {'notes': reason},
      description: 'Rejected expense #$expenseId: $reason',
    );
  }

  Future<void> addComment(String expenseId, String comment) async {
    final orgId = await _getCurrentOrgId();

    final oldExpense = await _client
        .from('expenses')
        .select()
        .eq('id', int.parse(expenseId))
        .eq('organization_id', orgId)
        .single();

    final existingNotes = oldExpense['notes'] as String? ?? '';
    // Prevent duplicate newlines if empty
    final newNotes = existingNotes.isEmpty ? comment : '$existingNotes\n---\n$comment';

    await _client
        .from('expenses')
        .update({
          'notes': newNotes,
        })
        .eq('id', int.parse(expenseId))
        .eq('organization_id', orgId);

    await _auditLogRepository.createAuditLog(
      organizationId: orgId,
      action: 'ADD_COMMENT',
      tableName: 'expenses',
      recordId: int.parse(expenseId),
      oldData: {'notes': existingNotes},
      newData: {'notes': newNotes},
      description: 'Added comment to expense #$expenseId',
    );
  }
}
