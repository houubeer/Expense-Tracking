/// Audit log model for tracking manager actions and changes
class AuditLog {
  final String id;
  final String organizationId;
  final String userId;
  final String userEmail;
  final String userName;
  final String action;
  final String tableName;
  final int? recordId;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final String? description;
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    required this.organizationId,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.action,
    required this.tableName,
    this.recordId,
    this.oldData,
    this.newData,
    this.description,
    required this.createdAt,
  });

  /// Get formatted action description
  String get actionDescription => description ?? action;

  /// Get display name for UI (user-friendly action name)
  String get displayAction {
    final actionLower = action.toLowerCase();
    if (actionLower.contains('approve')) return 'approved expense';
    if (actionLower.contains('reject')) return 'rejected expense';
    if (actionLower.contains('budget')) return 'updated budget';
    if (actionLower.contains('employee') && actionLower.contains('add')) {
      return 'added new employee';
    }
    if (actionLower.contains('suspend')) return 'suspended employee';
    if (actionLower.contains('activate')) return 'activated employee';
    if (actionLower.contains('remove')) return 'removed employee';
    if (actionLower.contains('comment')) return 'added comment';
    return action;
  }

  /// Legacy compatibility - use userName as managerName
  String get managerName => userName;

  /// Legacy compatibility - use createdAt as timestamp
  DateTime get timestamp => createdAt;

  /// Legacy compatibility - use description as details
  String get details => description ?? action;

  /// Legacy compatibility - use recordId as targetId
  String? get targetId => recordId?.toString();

  /// Get time ago string (e.g., "2 hours ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  /// Create AuditLog from JSON (database format)
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id']?.toString() ?? '',
      organizationId: json['organization_id'] as String,
      userId: json['user_id'] as String,
      userEmail: json['user_email'] as String,
      userName: json['user_name'] as String,
      action: json['action'] as String,
      tableName: json['table_name'] as String,
      recordId: json['record_id'] as int?,
      oldData: json['old_data'] as Map<String, dynamic>?,
      newData: json['new_data'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert AuditLog to JSON (database format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'user_id': userId,
      'user_email': userEmail,
      'user_name': userName,
      'action': action,
      'table_name': tableName,
      'record_id': recordId,
      'old_data': oldData,
      'new_data': newData,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  AuditLog copyWith({
    String? id,
    String? organizationId,
    String? userId,
    String? userEmail,
    String? userName,
    String? action,
    String? tableName,
    int? recordId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
    String? description,
    DateTime? createdAt,
  }) {
    return AuditLog(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      tableName: tableName ?? this.tableName,
      recordId: recordId ?? this.recordId,
      oldData: oldData ?? this.oldData,
      newData: newData ?? this.newData,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
