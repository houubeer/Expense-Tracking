import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budget_alerts_table.dart';

part 'budget_alert_dao.g.dart';

@DriftAccessor(tables: [BudgetAlerts])
class BudgetAlertDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetAlertDaoMixin {
  BudgetAlertDao(AppDatabase db) : super(db);

  // Get all alerts
  Future<List<BudgetAlert>> getAllAlerts() => select(budgetAlerts).get();

  // Get unread alerts
  Future<List<BudgetAlert>> getUnreadAlerts() => (select(budgetAlerts)
        ..where((a) => a.isRead.equals(false))
        ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
      .get();

  // Get alerts by category
  Future<List<BudgetAlert>> getAlertsByCategory(int categoryId) =>
      (select(budgetAlerts)
            ..where((a) => a.categoryId.equals(categoryId))
            ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
          .get();

  // Get alerts by type
  Future<List<BudgetAlert>> getAlertsByType(String alertType) =>
      (select(budgetAlerts)
            ..where((a) => a.alertType.equals(alertType))
            ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
          .get();

  // Add alert
  Future<int> addAlert(BudgetAlertsCompanion alert) =>
      into(budgetAlerts).insert(alert);

  // Mark alert as read
  Future<int> markAlertAsRead(int id) =>
      (update(budgetAlerts)..where((a) => a.id.equals(id)))
          .write(const BudgetAlertsCompanion(isRead: Value(true)));

  // Mark all alerts as read
  Future<int> markAllAlertsAsRead() =>
      (update(budgetAlerts)..where((a) => a.isRead.equals(false)))
          .write(const BudgetAlertsCompanion(isRead: Value(true)));

  // Mark category alerts as read
  Future<int> markCategoryAlertsAsRead(int categoryId) => (update(budgetAlerts)
        ..where(
            (a) => a.categoryId.equals(categoryId) & a.isRead.equals(false)))
      .write(const BudgetAlertsCompanion(isRead: Value(true)));

  // Delete alert
  Future<int> deleteAlert(int id) =>
      (delete(budgetAlerts)..where((a) => a.id.equals(id))).go();

  // Delete all read alerts
  Future<int> deleteReadAlerts() =>
      (delete(budgetAlerts)..where((a) => a.isRead.equals(true))).go();

  // Delete old alerts (older than specified days)
  Future<int> deleteOldAlerts(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return (delete(budgetAlerts)
          ..where((a) => a.createdAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  // Count unread alerts
  Future<int> countUnreadAlerts() async {
    final query = selectOnly(budgetAlerts)
      ..addColumns([budgetAlerts.id.count()])
      ..where(budgetAlerts.isRead.equals(false));

    final result = await query.getSingleOrNull();
    return result?.read(budgetAlerts.id.count()) ?? 0;
  }

  // Watch unread alerts (stream)
  Stream<List<BudgetAlert>> watchUnreadAlerts() => (select(budgetAlerts)
        ..where((a) => a.isRead.equals(false))
        ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
      .watch();

  // Watch all alerts (stream)
  Stream<List<BudgetAlert>> watchAllAlerts() =>
      (select(budgetAlerts)..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
          .watch();
}
