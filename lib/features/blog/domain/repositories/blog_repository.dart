import 'dart:io';

import 'package:bloc_app/core/errors/failure.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/entities/blog_change.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  });

  Future<Either<Failure, List<Blog>>> getBlogsPage(int pageNumber);

  Future<Either<Failure, int>> getBlogsCount();

  /// Emits domain-level blog change events (insert/update/delete).
  ///
  /// This is a passive, reactive data stream (not a user-triggered action),
  /// so it is exposed directly from the repository instead of via a use case.
  /// Pagination and other command-based operations remain handled by use cases.
  Stream<Either<Failure, BlogChange>> watchBlogChanges();
}
