import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:social_app/core/local_database/app_database.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/constants/blog_paging.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';

/// A blog local data source.
abstract interface class BlogLocalDataSource {
  /// Upserts a list of blogs into the local data source.
  Future<void> upsertBlogs(List<BlogModel> blogs);

  /// Gets a page of blogs from the local data source.
  Future<List<BlogModel>> getBlogsPage(int pageNumber);

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
                updatedAt: blog.updatedAt,
                posterName: blog.posterName,
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<List<BlogModel>> getBlogsPage(int pageNumber) async {
    final from = (pageNumber - 1) * blogPageSize;

    final cachedBlogs =
        await (_database.select(_database.cachedBlogs)
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.updatedAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(blogPageSize, offset: from))
            .get();

    return cachedBlogs
        .map(
          (cachedBlog) => BlogModel(
            id: cachedBlog.id,
            posterId: cachedBlog.posterId,
            title: cachedBlog.title,
            content: cachedBlog.content,
            imageUrl: cachedBlog.imageUrl,
            topics: List<String>.from(
              jsonDecode(cachedBlog.topicsJson) as List<dynamic>,
            ).map(BlogTopic.fromValue).toList(),
            updatedAt: cachedBlog.updatedAt,
            posterName: cachedBlog.posterName,
          ),
        )
        .toList();
  }

  @override
  Future<BlogModel?> getBlogById(String blogId) async {
    final query = _database.select(_database.cachedBlogs)
      ..where((table) => table.id.equals(blogId));

    final cachedBlog = await query.getSingleOrNull();

    if (cachedBlog == null) {
      return null;
    }

    return BlogModel(
      id: cachedBlog.id,
      posterId: cachedBlog.posterId,
      title: cachedBlog.title,
      content: cachedBlog.content,
      imageUrl: cachedBlog.imageUrl,
      topics: List<String>.from(
        jsonDecode(cachedBlog.topicsJson) as List<dynamic>,
      ).map(BlogTopic.fromValue).toList(),
      updatedAt: cachedBlog.updatedAt,
      posterName: cachedBlog.posterName,
    );
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
}
