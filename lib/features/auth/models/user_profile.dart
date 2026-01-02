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
  final bool isActive;
  final DateTime? lastSyncAt;
  final String? syncToken;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.organizationId,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.lastSyncAt,
    this.syncToken,
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String?,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] as String? ?? 'employee'),
      isActive: json['is_active'] as bool? ?? true,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      syncToken: json['sync_token'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'is_active': isActive,
      'last_sync_at': lastSyncAt?.toIso8601String(),
      'sync_token': syncToken,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? organizationId,
    String? email,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    bool? isActive,
    DateTime? lastSyncAt,
    String? syncToken,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      syncToken: syncToken ?? this.syncToken,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOwner => role == UserRole.owner;
  bool get isManager => role == UserRole.manager;
  bool get isEmployee => role == UserRole.employee;
}
