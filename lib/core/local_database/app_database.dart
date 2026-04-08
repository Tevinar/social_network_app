import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:social_app/core/local_database/schema/cached_blogs.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CachedBlogs])
/// The app database.
/// This is the main entry point for accessing the local database in the app.
class AppDatabase extends _$AppDatabase {
  /// Creates an instance of [AppDatabase].
  AppDatabase()
    : super(
        driftDatabase(
          name: 'social_app.sqlite',
          native: const DriftNativeOptions(),
        ),
      );

  // You should bump this number whenever you change or add a table definition.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await _migrateTo2(m);
      // Add more migration steps here as needed
      // when you increase the schema version.
    },
  );

  Future<void> _migrateTo2(Migrator m) async {
    // Implement the logic to migrate the database to version 2.
  }
}
