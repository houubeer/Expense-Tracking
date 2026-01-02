/// Employee status enumeration
enum EmployeeStatus {
  active,
  suspended;

  String get displayName {
    switch (this) {
      case EmployeeStatus.active:
        return 'Active';
      case EmployeeStatus.suspended:
        return 'Suspended';
    }
  }
}

/// Employee model representing a company employee
class Employee {
  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final DateTime hireDate;
  final EmployeeStatus status;
  final String? avatarUrl;
  final String? organizationId;

  const Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.hireDate,
    required this.status,
    this.avatarUrl,
    this.organizationId,
  });

  /// Get initials from employee name for avatar display
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  /// Create Employee from JSON (database format from user_profiles)
  factory Employee.fromJson(Map<String, dynamic> json) {
    // metadata/settings handling associated with user_profiles
    Map<String, dynamic> settings = {};
    if (json['settings'] != null) {
       if (json['settings'] is Map) {
         settings = json['settings'] as Map<String, dynamic>;
       } else if (json['settings'] is String) {
         // Handle case where settings is returned as stringified JSON
         try {
           // We can't import dart:convert here easily without checking imports, 
           // but Supabase usually handles this. If it's a string, it might be raw JSON.
           // However, let's just be safe and ignore if not a Map for now, 
           // or assume the caller handles it. 
           // actually, let's just try to cast if it's a map, else empty.
         } catch (_) {}
       }
    }
    
    // Better implementation:
    final rawSettings = json['settings'];
    if (rawSettings is Map) {
      settings = rawSettings as Map<String, dynamic>;
    }
    
    final dept = json['department'] as String? ?? 
                settings['department'] as String? ?? 
                'General';

    return Employee(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String? ?? '',
      role: json['role'] as String,
      department: dept,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      hireDate: json['hireDate'] != null || json['hire_date'] != null
          ? DateTime.parse((json['hire_date'] ?? json['hireDate']) as String)
          : DateTime.now(),
      status: _parseStatus(json['status']),
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      organizationId: json['organization_id'] as String?,
    );
  }

  /// Parse employee status from various formats
  static EmployeeStatus _parseStatus(dynamic status) {
    if (status == null) return EmployeeStatus.active;
    if (status is EmployeeStatus) return status;
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('suspend') || statusStr == 'inactive') {
      return EmployeeStatus.suspended;
    }
    return EmployeeStatus.active;
  }

  /// Convert Employee to JSON (database format for user_profiles)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': name,
      'role': role,
      'settings': {'department': department},
      'email': email,
      'phone': phone,
      'hire_date': hireDate.toIso8601String(),
      'status': status.name,
      'avatar_url': avatarUrl,
      'organization_id': organizationId,
    };
  }

  /// Create a copy with updated fields
  Employee copyWith({
    String? id,
    String? name,
    String? role,
    String? department,
    String? email,
    String? phone,
    DateTime? hireDate,
    EmployeeStatus? status,
    String? avatarUrl,
    String? organizationId,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hireDate: hireDate ?? this.hireDate,
      status: status ?? this.status,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}
