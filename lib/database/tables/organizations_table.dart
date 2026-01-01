import 'package:drift/drift.dart';

/// Organizations table for multi-tenant support
class Organizations extends Table {
  /// Local autoincrement ID
  IntColumn get id => integer().autoIncrement()();

  /// Supabase UUID (server ID)
  TextColumn get serverId => text().unique().nullable()();

  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get managerEmail => text()();

  /// Status: pending, approved, rejected
  TextColumn get status => text().withDefault(const Constant('pending'))();

  TextColumn get currency => text().withDefault(const Constant('USD'))();
  TextColumn get timezone => text().withDefault(const Constant('UTC'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
        'CREATE INDEX IF NOT EXISTS idx_organizations_status ON organizations(status)',
        'CREATE INDEX IF NOT EXISTS idx_organizations_manager_email ON organizations(manager_email)',
        'CREATE INDEX IF NOT EXISTS idx_organizations_synced ON organizations(is_synced)',
      ];
}
