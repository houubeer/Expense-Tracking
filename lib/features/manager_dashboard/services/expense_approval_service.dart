import '../models/expense_model.dart';
import '../models/audit_log_model.dart';

/// Service handling expense approval business logic
class ExpenseApprovalService {
  // In-memory storage for approved/rejected expenses (simulating state changes)
  final Map<String, ExpenseStatus> _expenseStatuses = {};
  final Map<String, String?> _expenseComments = {};
  final List<AuditLog> _auditLogs = [];

  /// Approve an expense
  /// Returns true if successful, false if expense cannot be approved
  Future<bool> approveExpense(String expenseId, String managerId,
      {String managerName = 'Manager'}) async {
    // Simulate processing delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Validate expense status (can only approve pending expenses)
    final currentStatus = _expenseStatuses[expenseId];
    if (currentStatus != null && currentStatus != ExpenseStatus.pending) {
      return false; // Already processed
    }

    // Update status
    _expenseStatuses[expenseId] = ExpenseStatus.approved;

    // Create audit log entry
    final auditLog = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      action: AuditAction.approved,
      managerName: managerName,
      timestamp: DateTime.now(),
      details: 'Approved expense #$expenseId',
      targetId: expenseId,
    );
    _auditLogs.add(auditLog);

    return true;
  }

  /// Reject an expense with a reason
  /// Returns true if successful, false if expense cannot be rejected
  Future<bool> rejectExpense(
    String expenseId,
    String managerId,
    String reason, {
    String managerName = 'Manager',
  }) async {
    // Simulate processing delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Validate expense status (can only reject pending expenses)
    final currentStatus = _expenseStatuses[expenseId];
    if (currentStatus != null && currentStatus != ExpenseStatus.pending) {
      return false; // Already processed
    }

    // Validate reason
    if (reason.trim().isEmpty) {
      throw ArgumentError('Rejection reason cannot be empty');
    }

    // Update status and comment
    _expenseStatuses[expenseId] = ExpenseStatus.rejected;
    _expenseComments[expenseId] = reason;

    // Create audit log entry
    final auditLog = AuditLog(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      action: AuditAction.rejected,
      managerName: managerName,
      timestamp: DateTime.now(),
      details: 'Rejected expense #$expenseId: $reason',
      targetId: expenseId,
    );
    _auditLogs.add(auditLog);

    return true;
  }

  /// Add a comment to an expense
  Future<void> addComment(String expenseId, String comment) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (comment.trim().isEmpty) {
      throw ArgumentError('Comment cannot be empty');
    }

    _expenseComments[expenseId] = comment;
  }

  /// Get current status of an expense
  ExpenseStatus? getExpenseStatus(String expenseId) {
    return _expenseStatuses[expenseId];
  }

  /// Get comment for an expense
  String? getExpenseComment(String expenseId) {
    return _expenseComments[expenseId];
  }

  /// Get all audit logs
  List<AuditLog> getAuditLogs() {
    return List.unmodifiable(_auditLogs.reversed);
  }

  /// Get recent audit logs (last N entries)
  List<AuditLog> getRecentAuditLogs({int limit = 10}) {
    final logs = _auditLogs.reversed.toList();
    return logs.take(limit).toList();
  }

  /// Clear all audit logs (for testing/reset)
  void clearAuditLogs() {
    _auditLogs.clear();
  }

  /// Reset all expense statuses (for testing/reset)
  void reset() {
    _expenseStatuses.clear();
    _expenseComments.clear();
    _auditLogs.clear();
  }
}
