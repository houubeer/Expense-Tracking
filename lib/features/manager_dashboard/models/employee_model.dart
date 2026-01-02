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
  });

  /// Create Employee from JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      department: json['department'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      hireDate: DateTime.parse(json['hireDate'] as String),
      status: EmployeeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EmployeeStatus.active,
      ),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final String phone;
  final DateTime hireDate;
  final EmployeeStatus status;
  final String? avatarUrl;

  /// Get initials from employee name for avatar display
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  /// Convert Employee to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'department': department,
      'email': email,
      'phone': phone,
      'hireDate': hireDate.toIso8601String(),
      'status': status.name,
      'avatarUrl': avatarUrl,
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
    );
  }
}
