/// Subscription plan enumeration
enum SubscriptionPlan {
  free,
  basic,
  premium,
  enterprise;

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.basic:
        return 29.99;
      case SubscriptionPlan.premium:
        return 79.99;
      case SubscriptionPlan.enterprise:
        return 199.99;
    }
  }
}

/// Subscription status enumeration
enum SubscriptionStatus {
  active,
  expired,
  cancelled;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Subscription model representing a company subscription
class Subscription {
  final String id;
  final String companyId;
  final SubscriptionPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;
  final double monthlyRevenue;

  const Subscription({
    required this.id,
    required this.companyId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.monthlyRevenue,
  });

  /// Create Subscription from JSON
  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      companyId: json['companyId'] as String,
      plan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['plan'],
        orElse: () => SubscriptionPlan.free,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
    );
  }

  /// Convert Subscription to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'plan': plan.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  /// Create a copy with updated fields
  Subscription copyWith({
    String? id,
    String? companyId,
    SubscriptionPlan? plan,
    DateTime? startDate,
    DateTime? endDate,
    SubscriptionStatus? status,
    double? monthlyRevenue,
  }) {
    return Subscription(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
    );
  }

  /// Check if subscription is currently active
  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);
}
