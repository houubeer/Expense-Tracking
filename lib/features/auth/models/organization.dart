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
  final OrganizationStatus status;
  final String currency;
  final String timezone;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.name,
    required this.managerEmail,
    required this.status,
    this.currency = 'USD',
    this.timezone = 'UTC',
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] as String,
      name: json['name'] as String,
      managerEmail: json['manager_email'] as String,
      status:
          OrganizationStatus.fromString(json['status'] as String? ?? 'pending'),
      currency: json['currency'] as String? ?? 'USD',
      timezone: json['timezone'] as String? ?? 'UTC',
      approvedBy: json['approved_by'] as String?,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manager_email': managerEmail,
      'status': status.value,
      'currency': currency,
      'timezone': timezone,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Organization copyWith({
    String? id,
    String? name,
    String? managerEmail,
    OrganizationStatus? status,
    String? currency,
    String? timezone,
    String? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      managerEmail: managerEmail ?? this.managerEmail,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == OrganizationStatus.pending;
  bool get isApproved => status == OrganizationStatus.approved;
  bool get isRejected => status == OrganizationStatus.rejected;
}
