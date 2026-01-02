/// Organization status enum
enum OrganizationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const OrganizationStatus(this.value);

  factory OrganizationStatus.fromString(String value) {
    return OrganizationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrganizationStatus.pending,
    );
  }
}

/// Organization model
class Organization {
  final String id; // Supabase UUID
  final String name;
  final String managerEmail;
  final String? managerName;
  final OrganizationStatus status;
  final DateTime? approvedAt;
  final int? fiscalYearStart;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;

  Organization({
    required this.id,
    required this.name,
    required this.managerEmail,
    this.managerName,
    required this.status,
    this.approvedAt,
    this.fiscalYearStart,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      managerEmail: json['manager_email'] as String,
      managerName: json['manager_name'] as String?,
      status:
          OrganizationStatus.fromString(json['status'] as String? ?? 'pending'),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      fiscalYearStart: json['fiscal_year_start'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manager_email': managerEmail,
      'manager_name': managerName,
      'status': status.value,
      'approved_at': approvedAt?.toIso8601String(),
      'fiscal_year_start': fiscalYearStart,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? managerEmail,
    String? managerName,
    OrganizationStatus? status,
    DateTime? approvedAt,
    int? fiscalYearStart,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      managerEmail: managerEmail ?? this.managerEmail,
      managerName: managerName ?? this.managerName,
      status: status ?? this.status,
      approvedAt: approvedAt ?? this.approvedAt,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Check if organization is approved
  bool get isApproved => status == OrganizationStatus.approved;

  /// Check if organization is pending
  bool get isPending => status == OrganizationStatus.pending;

  /// Check if organization is rejected
  bool get isRejected => status == OrganizationStatus.rejected;
}
