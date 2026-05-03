import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/blog/data/models/blog_feed_slice_model.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

/// A blog local data source.
abstract interface class BlogLocalDataSource {
  /// Upserts a list of blogs into the local data source.
  Future<void> upsertBlogs(List<BlogModel> blogs);

  /// Gets the first slice of the blog feed from the local data source.
  Future<BlogFeedSliceModel> getFirstFeedSlice({required int limit});

  /// Gets a blog by its ID from the local data source.
  Future<BlogModel?> getBlogById(String blogId);

  /// Deletes a blog from the local data source by its ID.
  Future<void> deleteBlog(String blogId);

  /// Clears all blogs from the local data source.
  Future<void> clearAll();
}

/// A blog local data source implementation using Drift.
class BlogLocalDataSourceDriftImpl implements BlogLocalDataSource {
  /// Creates an instance of [BlogLocalDataSourceDriftImpl].
  BlogLocalDataSourceDriftImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<void> upsertBlogs(List<BlogModel> blogs) async {
    await _database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _database.cachedBlogs,
        blogs
            .map(
              (blog) => CachedBlogsCompanion.insert(
                id: blog.id,
                posterId: blog.posterId,
                title: blog.title,
                content: blog.content,
                imageUrl: blog.imageUrl,
                topicsJson: jsonEncode(
                  blog.topics.map((topic) => topic.value).toList(),
                ),
                createdAt: blog.createdAt,
                updatedAt: blog.updatedAt,
                posterName: blog.posterName,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<BlogFeedSliceModel> getFirstFeedSlice({
    required int limit,
  }) async {
    final cachedBlogs =
        await (_database.select(_database.cachedBlogs)
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.createdAt,
                  mode: OrderingMode.desc,
                ),
                (table) => OrderingTerm(
                  expression: table.id,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .get();

    final items = cachedBlogs.map(_toBlogModel).toList();

    return BlogFeedSliceModel(
      items: items,
      nextCursor: null,
    );
  }

  @override
  Future<BlogModel?> getBlogById(String blogId) async {
    final query = _database.select(_database.cachedBlogs)
      ..where((table) => table.id.equals(blogId));

    final cachedBlog = await query.getSingleOrNull();

    if (cachedBlog == null) {
      return null;
    }

    return _toBlogModel(cachedBlog);
  }

  @override
  Future<void> deleteBlog(String blogId) async {
    final deleteStatement = _database.delete(_database.cachedBlogs)
      ..where((table) => table.id.equals(blogId));
    await deleteStatement.go();
  }

  @override
  Future<void> clearAll() async {
    await _database.delete(_database.cachedBlogs).go();
  }

  BlogModel _toBlogModel(CachedBlog cachedBlog) {
    return BlogModel(
      id: cachedBlog.id,
      posterId: cachedBlog.posterId,
      posterName: cachedBlog.posterName,
      title: cachedBlog.title,
      content: cachedBlog.content,
      imageUrl: cachedBlog.imageUrl,
      topics: List<String>.from(
        jsonDecode(cachedBlog.topicsJson) as List<dynamic>,
      ).map(BlogTopic.fromValue).toList(),
      createdAt: cachedBlog.createdAt,
      updatedAt: cachedBlog.updatedAt,
    );
  }
}
