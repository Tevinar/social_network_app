import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';

/// A blog repository.
abstract interface class BlogRepository {
  /// Create blog.
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });

  /// Gets the blogs page.
  Future<Either<Failure, List<Blog>>> getBlogsPage(int pageNumber);

  /// Gets the blogs count.
  Future<Either<Failure, int>> getBlogsCount();

  /// Emits domain-level blog change events (insert/update/delete).
  ///
  /// This is a passive, reactive data stream (not a user-triggered action),
  /// so it is exposed directly from the repository instead of via a use case.
  /// Pagination and other command-based operations remain handled by use cases.
  Stream<Either<Failure, BlogChange>> watchBlogChanges();

  /// Gets a blog by its ID.
  Future<Either<Failure, Blog>> getBlogById(String blogId);
}
