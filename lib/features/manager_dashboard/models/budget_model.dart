/// Department budget model for tracking budget allocation and usage
class DepartmentBudget {

  const DepartmentBudget({
    required this.departmentName,
    required this.totalBudget,
    required this.usedBudget,
  });

  /// Create DepartmentBudget from JSON
  factory DepartmentBudget.fromJson(Map<String, dynamic> json) {
    return DepartmentBudget(
      departmentName: json['departmentName'] as String,
      totalBudget: (json['totalBudget'] as num).toDouble(),
      usedBudget: (json['usedBudget'] as num).toDouble(),
    );
  }
  final String departmentName;
  final double totalBudget;
  final double usedBudget;

  /// Calculate remaining budget
  double get remainingBudget => totalBudget - usedBudget;

  /// Calculate usage percentage (0.0 to 1.0+)
  double get usagePercentage {
    if (totalBudget <= 0) return 0.0;
    return usedBudget / totalBudget;
  }

  /// Calculate usage percentage as integer (0 to 100+)
  int get usagePercentageInt => (usagePercentage * 100).round();

  /// Check if budget is exceeded
  bool get isExceeded => usedBudget > totalBudget;

  /// Check if budget is in warning zone (>= 70%)
  bool get isInWarning => usagePercentage >= 0.7;

  /// Check if budget is in danger zone (>= 90%)
  bool get isInDanger => usagePercentage >= 0.9;

  /// Convert DepartmentBudget to JSON
  Map<String, dynamic> toJson() {
    return {
      'departmentName': departmentName,
      'totalBudget': totalBudget,
      'usedBudget': usedBudget,
    };
  }

  /// Create a copy with updated fields
  DepartmentBudget copyWith({
    String? departmentName,
    double? totalBudget,
    double? usedBudget,
  }) {
    return DepartmentBudget(
      departmentName: departmentName ?? this.departmentName,
      totalBudget: totalBudget ?? this.totalBudget,
      usedBudget: usedBudget ?? this.usedBudget,
    );
  }
}
