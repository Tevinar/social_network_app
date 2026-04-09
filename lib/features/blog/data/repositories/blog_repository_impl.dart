import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_local_data_source.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:uuid/uuid.dart';

/// Repository implementation that maps blog data source results
/// to domain types.
class BlogRepositoryImpl implements BlogRepository {
  /// Creates a [BlogRepositoryImpl].
  BlogRepositoryImpl({
    required this.blogRemoteDataSource,
    required this.blogLocalDataSource,
  });

  /// Local data source used for caching blogs for offline access.
  final BlogLocalDataSource blogLocalDataSource;

  /// Remote data source used for blog persistence and realtime updates.
  final BlogRemoteDataSource blogRemoteDataSource;

  @override
  /// Uploads the image, persists the blog, and returns the created domain blog.
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required String posterName,
    required List<BlogTopic> topics,
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
        posterName: posterName,
      );

      final savedBlog = await blogRemoteDataSource.postBlog(
        blogModel,
      );

      await blogLocalDataSource.upsertBlogs([savedBlog]);

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
  Stream<Either<Failure, BlogsPageSnapshot>> watchBlogsPage(
    int pageNumber,
  ) async* {
    var cachedBlogs = const <BlogModel>[];

    try {
      cachedBlogs = await blogLocalDataSource.getBlogsPage(pageNumber);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchBlogsPage local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedBlogs.isNotEmpty) {
      yield right(
        BlogsPageSnapshot(
          pageNumber: pageNumber,
          blogs: cachedBlogs.map((blog) => blog.toEntity()).toList(),
          source: BlogsPageSource.cache,
        ),
      );
    }

    try {
      final remoteBlogs = await blogRemoteDataSource.getBlogsPage(pageNumber);
      await blogLocalDataSource.upsertBlogs(remoteBlogs);

      yield right(
        BlogsPageSnapshot(
          pageNumber: pageNumber,
          blogs: remoteBlogs.map((blog) => blog.toEntity()).toList(),
          source: BlogsPageSource.remote,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchBlogsPage',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedBlogs.isEmpty) {
        yield left(failure);
      } else {
        yield right(
          BlogsPageSnapshot(
            pageNumber: pageNumber,
            blogs: cachedBlogs.map((blog) => blog.toEntity()).toList(),
            source: BlogsPageSource.cache,
            refreshFailure: failure,
          ),
        );
      }
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
  Stream<Either<Failure, BlogSnapshot>> watchBlogById(String blogId) async* {
    BlogModel? cachedBlog;

    try {
      cachedBlog = await blogLocalDataSource.getBlogById(blogId);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchBlogById local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedBlog != null) {
      yield right(
        BlogSnapshot(
          blog: cachedBlog.toEntity(),
          source: BlogSource.cache,
        ),
      );
    }

    try {
      final remoteBlog = await blogRemoteDataSource.getBlogById(blogId);
      await blogLocalDataSource.upsertBlogs([remoteBlog]);

      yield right(
        BlogSnapshot(
          blog: remoteBlog.toEntity(),
          source: BlogSource.remote,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchBlogById',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedBlog == null) {
        yield left(failure);
      } else {
        yield right(
          BlogSnapshot(
            blog: cachedBlog.toEntity(),
            source: BlogSource.cache,
            refreshFailure: failure,
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, Blog>> getBlogById(String blogId) async {
    BlogModel? cachedBlog;

    try {
      cachedBlog = await blogLocalDataSource.getBlogById(blogId);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogById local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    try {
      final blog = await blogRemoteDataSource.getBlogById(blogId);
      await blogLocalDataSource.upsertBlogs([blog]);
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

      if (cachedBlog != null) {
        return right(cachedBlog.toEntity());
      }

      return left(failure);
    }
  }
}
