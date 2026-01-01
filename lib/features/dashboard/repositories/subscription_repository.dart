import 'dart:async';
import 'package:expense_tracking_desktop_app/features/dashboard/models/subscription_model.dart';

/// Repository for managing subscription data with in-memory mocked storage
class SubscriptionRepository {
  final List<Subscription> _subscriptions = [];
  final StreamController<List<Subscription>> _subscriptionsController =
      StreamController<List<Subscription>>.broadcast();

  SubscriptionRepository() {
    _initializeMockData();
  }

  /// Initialize with mock data
  void _initializeMockData() {
    final now = DateTime.now();
    _subscriptions.addAll([
      Subscription(
        id: 's1',
        companyId: 'c1',
        plan: SubscriptionPlan.enterprise,
        startDate: DateTime(2023, 1, 15),
        endDate: DateTime(2024, 1, 15),
        status: SubscriptionStatus.active,
        monthlyRevenue: 199.99,
      ),
      Subscription(
        id: 's2',
        companyId: 'c2',
        plan: SubscriptionPlan.premium,
        startDate: DateTime(2023, 3, 22),
        endDate: DateTime(2024, 3, 22),
        status: SubscriptionStatus.active,
        monthlyRevenue: 79.99,
      ),
      Subscription(
        id: 's3',
        companyId: 'c3',
        plan: SubscriptionPlan.basic,
        startDate: DateTime(2023, 6, 10),
        endDate: DateTime(2024, 6, 10),
        status: SubscriptionStatus.active,
        monthlyRevenue: 29.99,
      ),
      Subscription(
        id: 's4',
        companyId: 'c4',
        plan: SubscriptionPlan.enterprise,
        startDate: DateTime(2022, 11, 5),
        endDate: DateTime(2023, 11, 5),
        status: SubscriptionStatus.active,
        monthlyRevenue: 199.99,
      ),
      Subscription(
        id: 's5',
        companyId: 'c5',
        plan: SubscriptionPlan.basic,
        startDate: DateTime(2023, 8, 18),
        endDate: DateTime(2023, 10, 18),
        status: SubscriptionStatus.expired,
        monthlyRevenue: 0.0,
      ),
    ]);
    _notifyListeners();
  }

  /// Get all subscriptions
  List<Subscription> getAll() {
    return List.unmodifiable(_subscriptions);
  }

  /// Watch all subscriptions (stream)
  Stream<List<Subscription>> watchAll() {
    return _subscriptionsController.stream;
  }

  /// Get subscription by ID
  Subscription? getById(String id) {
    try {
      return _subscriptions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get subscription by company ID
  Subscription? getByCompanyId(String companyId) {
    try {
      return _subscriptions.firstWhere((s) => s.companyId == companyId);
    } catch (e) {
      return null;
    }
  }

  /// Get active subscriptions
  List<Subscription> getActive() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
  }

  /// Get expired subscriptions
  List<Subscription> getExpired() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.expired)
        .toList();
  }

  /// Create new subscription
  Future<Subscription> create(Subscription subscription) async {
    _subscriptions.add(subscription);
    _notifyListeners();
    return subscription;
  }

  /// Update existing subscription
  Future<Subscription> update(Subscription subscription) async {
    final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
    if (index == -1) {
      throw Exception('Subscription not found');
    }
    _subscriptions[index] = subscription;
    _notifyListeners();
    return subscription;
  }

  /// Delete subscription
  Future<void> delete(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    _notifyListeners();
  }

  /// Get total active subscriptions count
  int getActiveCount() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .length;
  }

  /// Get total expired subscriptions count
  int getExpiredCount() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.expired)
        .length;
  }

  /// Calculate total monthly revenue
  double getTotalMonthlyRevenue() {
    return _subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .fold(0.0, (sum, s) => sum + s.monthlyRevenue);
  }

  /// Get subscription distribution by plan
  Map<SubscriptionPlan, int> getDistributionByPlan() {
    final distribution = <SubscriptionPlan, int>{};
    for (final plan in SubscriptionPlan.values) {
      distribution[plan] = _subscriptions
          .where((s) => s.plan == plan && s.status == SubscriptionStatus.active)
          .length;
    }
    return distribution;
  }

  /// Notify listeners of changes
  void _notifyListeners() {
    _subscriptionsController.add(List.unmodifiable(_subscriptions));
  }

  /// Dispose resources
  void dispose() {
    _subscriptionsController.close();
  }
}
