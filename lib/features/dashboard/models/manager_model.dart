/// Manager status enumeration
enum ManagerStatus {
  pending,
  approved,
  rejected,
  suspended;

  String get displayName {
    switch (this) {
      case ManagerStatus.pending:
        return 'Pending';
      case ManagerStatus.approved:
        return 'Approved';
      case ManagerStatus.rejected:
        return 'Rejected';
      case ManagerStatus.suspended:
        return 'Suspended';
    }
  }
}

/// Manager model representing a company manager in the platform
class Manager {
  final String id;
  final String name;
  final String email;
  final String companyId;
  final String companyName;
  final String phone;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final ManagerStatus status;

  const Manager({
    required this.id,
    required this.name,
    required this.email,
    required this.companyId,
    required this.companyName,
    required this.phone,
    required this.requestDate,
    this.approvalDate,
    required this.status,
  });

  /// Get initials from manager name for avatar display
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  /// Create Manager from JSON
  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      companyId: json['companyId'] as String,
      companyName: json['companyName'] as String,
      phone: json['phone'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      status: ManagerStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ManagerStatus.pending,
      ),
    );
  }

  /// Convert Manager to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'companyId': companyId,
      'companyName': companyName,
      'phone': phone,
      'requestDate': requestDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'status': status.name,
    };
  }

  /// Create a copy with updated fields
  Manager copyWith({
    String? id,
    String? name,
    String? email,
    String? companyId,
    String? companyName,
    String? phone,
    DateTime? requestDate,
    DateTime? approvalDate,
    ManagerStatus? status,
  }) {
    return Manager(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      phone: phone ?? this.phone,
      requestDate: requestDate ?? this.requestDate,
      approvalDate: approvalDate ?? this.approvalDate,
      status: status ?? this.status,
    );
  }
}
