/// Audit action enumeration for tracking manager actions
enum AuditAction {
  approved,
  rejected,
  budgetUpdated,
  employeeAdded;

  String get displayName {
    switch (this) {
      case AuditAction.approved:
        return 'Approved';
      case AuditAction.rejected:
        return 'Rejected';
      case AuditAction.budgetUpdated:
        return 'Budget Updated';
      case AuditAction.employeeAdded:
        return 'Employee Added';
    }
  }
}

/// Audit log model for tracking manager actions and changes
class AuditLog {

  const AuditLog({
    required this.id,
    required this.action,
    required this.managerName,
    required this.timestamp,
    required this.details,
    this.targetId,
  });

  /// Create AuditLog from JSON
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      action: AuditAction.values.firstWhere(
        (e) => e.name == json['action'],
        orElse: () => AuditAction.approved,
      ),
      managerName: json['managerName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as String,
      targetId: json['targetId'] as String?,
    );
  }
  final String id;
  final AuditAction action;
  final String managerName;
  final DateTime timestamp;
  final String details;
  final String? targetId;

  /// Get formatted action description
  String get actionDescription {
    switch (action) {
      case AuditAction.approved:
        return 'approved expense';
      case AuditAction.rejected:
        return 'rejected expense';
      case AuditAction.budgetUpdated:
        return 'updated budget';
      case AuditAction.employeeAdded:
        return 'added new employee';
    }
  }

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Convert AuditLog to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'managerName': managerName,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
      'targetId': targetId,
    };
  }

  /// Create a copy with updated fields
  AuditLog copyWith({
    String? id,
    AuditAction? action,
    String? managerName,
    DateTime? timestamp,
    String? details,
    String? targetId,
  }) {
    return AuditLog(
      id: id ?? this.id,
      action: action ?? this.action,
      managerName: managerName ?? this.managerName,
      timestamp: timestamp ?? this.timestamp,
      details: details ?? this.details,
      targetId: targetId ?? this.targetId,
    );
  }
}
