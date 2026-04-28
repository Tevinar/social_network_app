import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/core/local_database/schema/app_settings.dart';

/// Store for reading and writing app-wide settings.
abstract interface class AppSettingsStore {
  /// Returns the stored value for [key], or `null` when it does not exist.
  Future<String?> get(AppSettingKey key);

  /// Persists [value] for [key].
  Future<void> set(AppSettingKey key, String value);

  /// Returns the stored value for [key], creating it when it does not exist.
  Future<String> getOrCreate({
    required AppSettingKey key,
    required String Function() create,
  });
}

/// Drift-backed implementation of [AppSettingsStore].
class DriftAppSettingsStore implements AppSettingsStore {
  /// Creates a [DriftAppSettingsStore].
  DriftAppSettingsStore(this._database);

  final AppDatabase _database;

  @override
  Future<String?> get(AppSettingKey key) async {
    final row = await (_database.select(
      _database.appSettings,
    )..where((table) => table.key.equals(key.rawKey))).getSingleOrNull();

    return row?.value;
  }

  @override
  Future<void> set(AppSettingKey key, String value) {
    return _database
        .into(_database.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: key.rawKey,
            value: value,
          ),
        );
  }

  @override
  Future<String> getOrCreate({
    required AppSettingKey key,
    required String Function() create,
  }) async {
    final existing = await get(key);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final value = create();
    await set(key, value);
    return value;
  }
}
