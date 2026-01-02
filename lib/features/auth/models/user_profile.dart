/// User role enum
enum UserRole {
  owner('owner'),
  manager('manager'),
  employee('employee');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.employee,
    );
  }
}

/// User profile model
class UserProfile {
  final String id; // Supabase UUID
  final String? organizationId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;
  final DateTime? lastSyncAt;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? status; // 'active', 'pending', 'inactive', etc.

  UserProfile({
    required this.id,
    this.organizationId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.lastSyncAt,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role.value,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  UserProfile copyWith({
    String? id,
    String? organizationId,
    String? email,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    DateTime? lastSyncAt,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  bool get isOwner => role == UserRole.owner;
  bool get isManager => role == UserRole.manager;
  bool get isEmployee => role == UserRole.employee;

  /// Check if user is active (status is 'active' or null for backwards compatibility)
  bool get isActive => status == 'active' || status == null;

  /// Check if user is pending approval
  bool get isPending => status == 'pending';
}
