import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';

/// A blog repository.
abstract interface class BlogRepository {
  /// Create blog.
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required String posterName,
    required List<BlogTopic> topics,
  });

  /// Watches a page of blogs, emitting cached data immediately
  /// and remote updates.
  Stream<Either<Failure, BlogsPageSnapshot>> watchBlogsPage(
    int pageNumber,
  );

  /// Gets the blogs count.
  Future<Either<Failure, int>> getBlogsCount();

  /// Emits domain-level blog change events (insert/update/delete).
  ///
  /// This is a passive, reactive data stream (not a user-triggered action).
  Stream<Either<Failure, BlogChange>> watchBlogChanges();

  /// Watches a single blog, emitting cached data first and remote updates.
  Stream<Either<Failure, BlogSnapshot>> watchBlogById(String blogId);

  /// Gets a blog by its ID.
  Future<Either<Failure, Blog>> getBlogById(String blogId);
}
