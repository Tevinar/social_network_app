import 'package:drift/drift.dart';

/// Table for storing blogs cached in the local database.
class CachedBlogs extends Table {
  /// The unique identifier for the blog.
  /// This is the primary key for the table.
  TextColumn get id => text()();

  /// The identifier of the user who posted the blog.
  TextColumn get posterId => text()();

  /// The title of the blog.
  TextColumn get title => text()();

  /// The content of the blog.
  TextColumn get content => text()();

  /// The URL of the image associated with the blog.
  TextColumn get imageUrl => text()();

  /// The JSON string representing the topics of the blog.
  TextColumn get topicsJson => text()();

  /// The date and time when the blog was created.
  DateTimeColumn get createdAt => dateTime()();

  /// The date and time when the blog was last updated.
  DateTimeColumn get updatedAt => dateTime()();

  /// The name of the user who posted the blog.
  TextColumn get posterName => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
