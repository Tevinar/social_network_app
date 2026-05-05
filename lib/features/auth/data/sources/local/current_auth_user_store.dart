import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';

/// Local store for the current authenticated user profile.
abstract interface class CurrentAuthUserStore {
  /// Watches the stored current authenticated user.
  ///
  /// The stream first emits the current user, then emits each later change
  /// caused by [saveCurrentUser] or [clearCurrentUser].
  Stream<UserModel?> watchCurrentUser();

  /// Persists [user] as the current authenticated user.
  Future<void> saveCurrentUser(UserModel user);

  /// Clears the stored current authenticated user.
  Future<void> clearCurrentUser();
}

/// Drift-backed implementation of [CurrentAuthUserStore].
class DriftCurrentAuthUserStore implements CurrentAuthUserStore {
  /// Creates a [DriftCurrentAuthUserStore].
  DriftCurrentAuthUserStore(this._database);

  final AppDatabase _database;

  @override
  Stream<UserModel?> watchCurrentUser() {
    return (_database.select(
      _database.currentAuthUsers,
    )..where((table) => table.singletonKey.equals(0))).watchSingleOrNull().map((
      row,
    ) {
      if (row == null) {
        return null;
      }

      return _toUserModel(row);
    });
  }

  @override
  Future<void> saveCurrentUser(UserModel user) {
    return _database
        .into(_database.currentAuthUsers)
        .insertOnConflictUpdate(
          CurrentAuthUsersCompanion.insert(
            id: user.id,
            email: user.email,
            name: user.name,
          ),
        );
  }

  @override
  Future<void> clearCurrentUser() {
    return _database.delete(_database.currentAuthUsers).go();
  }

  UserModel _toUserModel(CurrentAuthUser row) {
    return UserModel(
      id: row.id,
      name: row.name,
      email: row.email,
    );
  }
}
