import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:uuid/uuid.dart';

/// Repository implementation that maps blog data source results
/// to domain types.
class BlogRepositoryImpl implements BlogRepository {
  /// Creates a [BlogRepositoryImpl].
  BlogRepositoryImpl({required this.blogRemoteDataSource});

  /// Remote data source used for blog persistence and realtime updates.
  final BlogRemoteDataSource blogRemoteDataSource;

  @override
  /// Uploads the image, persists the blog, and returns the created domain blog.
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      final blogId = const Uuid().v1();
      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blogId: blogId,
      );

      final blogModel = BlogModel(
        id: blogId,
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: imageUrl,
        topics: topics,
        updatedAt: DateTime.now(),
      );

      final savedBlog = await blogRemoteDataSource.postBlog(
        blogModel,
      );

      return right(savedBlog.toEntity());
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.createBlog',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  /// Fetches a page of blogs and maps the models to domain entities.
  Future<Either<Failure, List<Blog>>> getBlogsPage(int pageNumber) async {
    try {
      final blogs = await blogRemoteDataSource.getBlogsPage(
        pageNumber,
      );
      return right(blogs.map((blogModel) => blogModel.toEntity()).toList());
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogsPage',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  /// Fetches the total number of blogs available in the backend.
  Future<Either<Failure, int>> getBlogsCount() async {
    try {
      final blogsCount = await blogRemoteDataSource.getBlogsCount();
      return right(blogsCount);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogsCount',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  /// Streams realtime blog changes mapped to domain-level change objects.
  Stream<Either<Failure, BlogChange>> watchBlogChanges() async* {
    try {
      await for (final BlogChange blogChange
          in blogRemoteDataSource.watchBlogChanges()) {
        yield right(blogChange);
      }
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchBlogChanges',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Any unexpected stream error is translated into a Failure
      yield left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, Blog>> getBlogById(String blogId) async {
    try {
      final blog = await blogRemoteDataSource.getBlogById(blogId);
      return right(blog.toEntity());
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogById',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }
}
