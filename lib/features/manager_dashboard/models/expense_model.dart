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

  const ManagerExpense({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.category,
    required this.date,
    this.receiptUrl,
    required this.status,
    this.comment,
    this.description,
  });

  /// Create ManagerExpense from JSON
  factory ManagerExpense.fromJson(Map<String, dynamic> json) {
    return ManagerExpense(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      comment: json['comment'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Convert ManagerExpense to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'receiptUrl': receiptUrl,
      'status': status.name,
      'comment': comment,
      'description': description,
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
    );
  }

  /// Check if expense is pending approval
  bool get isPending => status == ExpenseStatus.pending;

  /// Check if expense is approved
  bool get isApproved => status == ExpenseStatus.approved;

  /// Check if expense is rejected
  bool get isRejected => status == ExpenseStatus.rejected;
}
