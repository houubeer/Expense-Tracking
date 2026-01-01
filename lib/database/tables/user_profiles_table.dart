import 'package:drift/drift.dart';
import 'organizations_table.dart';

/// User profiles table (extends Supabase auth.users)
class UserProfiles extends Table {
  /// Local autoincrement ID
  IntColumn get id => integer().autoIncrement()();

  /// Supabase UUID (server ID and auth.users id)
  TextColumn get serverId => text().unique().nullable()();

  /// Foreign key to organizations
  IntColumn get organizationId =>
      integer().nullable().references(Organizations, #id)();

  TextColumn get email => text().unique()();
  TextColumn get fullName => text().nullable()();

  /// Role: owner, manager, employee
  TextColumn get role => text().withDefault(const Constant('employee'))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// User settings as JSON
  TextColumn get settings => text().withDefault(const Constant('{}'))();

  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get syncToken => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
        'FOREIGN KEY (organization_id) REFERENCES organizations (id) ON DELETE CASCADE',
        'CREATE INDEX IF NOT EXISTS idx_user_profiles_org ON user_profiles(organization_id)',
        'CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role)',
        'CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email)',
        'CREATE INDEX IF NOT EXISTS idx_user_profiles_synced ON user_profiles(is_synced)',
      ];
}
