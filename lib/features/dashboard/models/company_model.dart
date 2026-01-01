/// Company status enumeration
enum CompanyStatus {
  active,
  suspended,
  inactive;

  String get displayName {
    switch (this) {
      case CompanyStatus.active:
        return 'Active';
      case CompanyStatus.suspended:
        return 'Suspended';
      case CompanyStatus.inactive:
        return 'Inactive';
    }
  }
}

/// Company model representing a registered company in the platform
class Company {
  final String id;
  final String name;
  final int managersCount;
  final int employeesCount;
  final String subscriptionPlan;
  final CompanyStatus status;
  final DateTime createdDate;

  const Company({
    required this.id,
    required this.name,
    required this.managersCount,
    required this.employeesCount,
    required this.subscriptionPlan,
    required this.status,
    required this.createdDate,
  });

  /// Create Company from JSON
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String,
      name: json['name'] as String,
      managersCount: json['managersCount'] as int,
      employeesCount: json['employeesCount'] as int,
      subscriptionPlan: json['subscriptionPlan'] as String,
      status: CompanyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CompanyStatus.active,
      ),
      createdDate: DateTime.parse(json['createdDate'] as String),
    );
  }

  /// Convert Company to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'managersCount': managersCount,
      'employeesCount': employeesCount,
      'subscriptionPlan': subscriptionPlan,
      'status': status.name,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  Company copyWith({
    String? id,
    String? name,
    int? managersCount,
    int? employeesCount,
    String? subscriptionPlan,
    CompanyStatus? status,
    DateTime? createdDate,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      managersCount: managersCount ?? this.managersCount,
      employeesCount: employeesCount ?? this.employeesCount,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
