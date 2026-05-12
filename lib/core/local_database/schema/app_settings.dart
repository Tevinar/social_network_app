import 'package:drift/drift.dart';

/// Table storing app-wide key/value settings.
class AppSettings extends Table {
  /// Stable setting identifier.
  TextColumn get key => text()();

  /// Persisted setting value.
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Type-safe keys used to access rows in [AppSettings].
enum AppSettingKey {
  /// App-install identifier sent to the backend for session binding.
  deviceId('device_id')
  ;

  /// Creates an [AppSettingKey] backed by [rawKey].
  const AppSettingKey(this.rawKey);

  /// Raw key persisted in the local database.
  final String rawKey;
}
