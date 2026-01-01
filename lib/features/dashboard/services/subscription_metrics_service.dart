import 'package:expense_tracking_desktop_app/features/dashboard/models/subscription_model.dart';
import 'package:expense_tracking_desktop_app/features/dashboard/repositories/subscription_repository.dart';

/// Service for calculating subscription and revenue metrics
/// Provides insights into subscription status and revenue generation
class SubscriptionMetricsService {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionMetricsService(this._subscriptionRepository);

  /// Calculate total monthly revenue from active subscriptions
  double calculateMonthlyRevenue() {
    return _subscriptionRepository.getTotalMonthlyRevenue();
  }

  /// Get count of active subscriptions
  int getActiveSubscriptionsCount() {
    return _subscriptionRepository.getActiveCount();
  }

  /// Get count of expired subscriptions
  int getExpiredSubscriptionsCount() {
    return _subscriptionRepository.getExpiredCount();
  }

  /// Get subscription distribution by plan
  Map<SubscriptionPlan, int> getPlanDistribution() {
    return _subscriptionRepository.getDistributionByPlan();
  }

  /// Calculate annual revenue projection
  double calculateAnnualRevenue() {
    return calculateMonthlyRevenue() * 12;
  }

  /// Get upgrade activity (count of premium and enterprise plans)
  int getUpgradeActivity() {
    final distribution = getPlanDistribution();
    final premium = distribution[SubscriptionPlan.premium] ?? 0;
    final enterprise = distribution[SubscriptionPlan.enterprise] ?? 0;
    return premium + enterprise;
  }

  /// Get subscription health percentage
  /// Based on ratio of active to total subscriptions
  double getSubscriptionHealth() {
    final active = getActiveSubscriptionsCount();
    final expired = getExpiredSubscriptionsCount();
    final total = active + expired;
    
    if (total == 0) return 100.0;
    return (active / total) * 100;
  }

  /// Get revenue by plan
  Map<SubscriptionPlan, double> getRevenueByPlan() {
    final distribution = getPlanDistribution();
    return distribution.map((plan, count) => 
      MapEntry(plan, plan.monthlyPrice * count)
    );
  }

  /// Get most popular plan
  SubscriptionPlan getMostPopularPlan() {
    final distribution = getPlanDistribution();
    var mostPopular = SubscriptionPlan.free;
    var maxCount = 0;
    
    distribution.forEach((plan, count) {
      if (count > maxCount) {
        maxCount = count;
        mostPopular = plan;
      }
    });
    
    return mostPopular;
  }

  /// Get subscription metrics summary
  SubscriptionMetrics getMetrics() {
    return SubscriptionMetrics(
      monthlyRevenue: calculateMonthlyRevenue(),
      annualRevenue: calculateAnnualRevenue(),
      activeCount: getActiveSubscriptionsCount(),
      expiredCount: getExpiredSubscriptionsCount(),
      upgradeActivity: getUpgradeActivity(),
      health: getSubscriptionHealth(),
      mostPopularPlan: getMostPopularPlan(),
    );
  }

  /// Check if subscription needs renewal soon (within 30 days)
  List<Subscription> getSubscriptionsNeedingRenewal() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    
    return _subscriptionRepository
        .getActive()
        .where((s) => s.endDate.isBefore(thirtyDaysFromNow))
        .toList();
  }
}

/// Data class for subscription metrics
class SubscriptionMetrics {
  final double monthlyRevenue;
  final double annualRevenue;
  final int activeCount;
  final int expiredCount;
  final int upgradeActivity;
  final double health;
  final SubscriptionPlan mostPopularPlan;

  const SubscriptionMetrics({
    required this.monthlyRevenue,
    required this.annualRevenue,
    required this.activeCount,
    required this.expiredCount,
    required this.upgradeActivity,
    required this.health,
    required this.mostPopularPlan,
  });
}
