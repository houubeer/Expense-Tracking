import 'package:drift/drift.dart';
import 'organizations_table.dart';

/// User profiles table (extends Supabase auth.users)
@TableIndex(name: 'idx_user_profiles_org', columns: {#organizationId})
@TableIndex(name: 'idx_user_profiles_role', columns: {#role})
@TableIndex(name: 'idx_user_profiles_email', columns: {#email})
@TableIndex(name: 'idx_user_profiles_synced', columns: {#isSynced})
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

  /// User status: 'active', 'pending', 'inactive', etc.
  TextColumn get status => text().nullable()();

  /// Avatar URL
  TextColumn get avatarUrl => text().nullable()();

  /// User settings as JSON
  TextColumn get settings => text().withDefault(const Constant('{}'))();

  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
