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

class UserProfile {
  final String id; // Supabase UUID
  final String? organizationId;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final UserRole role;
  final DateTime? lastSyncAt;
  final String? syncToken;
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
    this.syncToken,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> settings = {};
    if (json['settings'] != null) {
      final rawSettings = json['settings'];
      if (rawSettings is Map) {
        settings = rawSettings as Map<String, dynamic>;
      } else if (rawSettings is String) {
        // Optionally: parse stringified JSON if needed
      }
    }

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
      syncToken: json['sync_token'] as String?,
      settings: settings,
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
      'sync_token': syncToken,
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
    String? syncToken,
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
      syncToken: syncToken ?? this.syncToken,
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
