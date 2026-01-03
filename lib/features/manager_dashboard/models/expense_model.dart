/// Expense status enumeration for manager approval workflow
enum ExpenseStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ExpenseStatus.pending:
        return 'Pending';
      case ExpenseStatus.approved:
        return 'Approved';
      case ExpenseStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Manager expense model representing an employee expense submission
class ManagerExpense {
  final String id;
  final String employeeId;
  final String employeeName;
  final double amount;
  final String category;
  final DateTime date;
  final String? receiptUrl;
  final ExpenseStatus status;
  final String? comment;
  final String? description;
  final String? organizationId;
  final String? budgetId;
  final List<String>? receiptUrls;
  final bool? isReimbursable;
  final DateTime? reimbursedAt;
  final String? notes;

  const ManagerExpense({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.category,
    required this.date,
    required this.status,
    this.receiptUrl,
    this.comment,
    this.description,
    this.organizationId,
    this.budgetId,
    this.receiptUrls,
    this.isReimbursable,
    this.reimbursedAt,
    this.notes,
  });

  /// Create ManagerExpense from JSON (database format)
  factory ManagerExpense.fromJson(Map<String, dynamic> json) {
    // Handle receipt URLs - can be single URL or array
    List<String>? receipts;
    if (json['receipt_urls'] != null) {
      if (json['receipt_urls'] is List) {
        receipts = List<String>.from(json['receipt_urls'] as List);
      } else {
        receipts = [json['receipt_urls'] as String];
      }
    }

    return ManagerExpense(
      id: json['id']?.toString() ?? '',
      employeeId: json['created_by']?.toString() ??
          json['employeeId']?.toString() ??
          '',
      employeeName: json['employeeName'] as String? ??
          json['employee_name'] as String? ??
          'Unknown',
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String? ??
          json['description'] as String? ??
          'Other',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      receiptUrl: receipts?.isNotEmpty == true ? receipts!.first : null,
      receiptUrls: receipts,
      status: _parseStatus(json['status']),
      comment: json['comment'] as String? ?? json['notes'] as String?,
      description: json['description'] as String?,
      organizationId: json['organization_id'] as String?,
      budgetId: json['budget_id']?.toString(),
      isReimbursable: json['is_reimbursable'] as bool?,
      reimbursedAt: json['reimbursed_at'] != null
          ? DateTime.parse(json['reimbursed_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Parse expense status from various formats
  static ExpenseStatus _parseStatus(dynamic status) {
    if (status == null) return ExpenseStatus.pending;
    if (status is ExpenseStatus) return status;
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('approve')) return ExpenseStatus.approved;
    if (statusStr.contains('reject')) return ExpenseStatus.rejected;
    if (statusStr.contains('pending')) return ExpenseStatus.pending;
    return ExpenseStatus.pending;
  }

  /// Convert ManagerExpense to JSON (database format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_by': employeeId,
      'amount': amount,
      'description': description ?? category,
      'date': date.toIso8601String().split('T')[0],
      'receipt_urls':
          receiptUrls ?? (receiptUrl != null ? [receiptUrl!] : null),
      'status': status.name,
      'notes': notes ?? comment,
      'organization_id': organizationId,
      'budget_id': budgetId != null ? int.tryParse(budgetId!) : null,
      'is_reimbursable': isReimbursable,
      'reimbursed_at': reimbursedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  ManagerExpense copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    double? amount,
    String? category,
    DateTime? date,
    String? receiptUrl,
    ExpenseStatus? status,
    String? comment,
    String? description,
    String? organizationId,
    String? budgetId,
    List<String>? receiptUrls,
    bool? isReimbursable,
    DateTime? reimbursedAt,
    String? notes,
  }) {
    return ManagerExpense(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      description: description ?? this.description,
      organizationId: organizationId ?? this.organizationId,
      budgetId: budgetId ?? this.budgetId,
      receiptUrls: receiptUrls ?? this.receiptUrls,
      isReimbursable: isReimbursable ?? this.isReimbursable,
      reimbursedAt: reimbursedAt ?? this.reimbursedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Check if expense is pending approval
  bool get isPending => status == ExpenseStatus.pending;

  /// Check if expense is approved
  bool get isApproved => status == ExpenseStatus.approved;

  /// Check if expense is rejected
  bool get isRejected => status == ExpenseStatus.rejected;
}
