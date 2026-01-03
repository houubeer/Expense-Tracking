import 'package:drift/drift.dart';

/// Organizations table for multi-tenant support
@TableIndex(name: 'idx_organizations_status', columns: {#status})
@TableIndex(name: 'idx_organizations_manager_email', columns: {#managerEmail})
@TableIndex(name: 'idx_organizations_synced', columns: {#isSynced})
class Organizations extends Table {
  /// Local autoincrement ID
  IntColumn get id => integer().autoIncrement()();

  /// Supabase UUID (server ID)
  TextColumn get serverId => text().unique().nullable()();

  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get managerEmail => text()();
  TextColumn get managerName => text().nullable()();

  /// Status: pending, approved, rejected
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Fiscal year start month (1-12)
  IntColumn get fiscalYearStart => integer().nullable()();

  DateTimeColumn get approvedAt => dateTime().nullable()();

  /// Who created this organization (user_profile id)
  TextColumn get createdBy => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
