import 'package:drift/drift.dart';

/// Singleton table storing the current authenticated user profile.
class CurrentAuthUsers extends Table {
  /// Singleton row identifier used to keep at most one current user row.
  IntColumn get singletonKey => integer().withDefault(const Constant(0))();

  /// Current authenticated user identifier.
  TextColumn get id => text()();

  /// Current authenticated user email address.
  TextColumn get email => text()();

  /// Current authenticated user display name.
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {singletonKey};
}
