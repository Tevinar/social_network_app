import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_local_data_source.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_list_slice_model.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/read_models/blog_list_slice.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

/// Repository implementation that composes blog local and remote data sources
/// into cache-first domain operations.
class BlogRepositoryImpl implements BlogRepository {
  /// Creates a [BlogRepositoryImpl].
  BlogRepositoryImpl({
    required this.blogRemoteDataSource,
    required this.blogLocalDataSource,
    required this.imageFileCache,
  });

  /// Remote data source used for backend blog operations.
  final BlogRemoteDataSource blogRemoteDataSource;

  /// Local data source used for caching the first list slice and individual
  /// blog records.
  final BlogLocalDataSource blogLocalDataSource;

  /// Cache used to persist blog images locally after download.
  final ImageFileCache imageFileCache;

  @override
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required List<BlogTopic> topics,
  }) async {
    try {
      final blog = await blogRemoteDataSource.createBlog(
        title: title,
        content: content,
        image: image,
        topics: topics.map((topic) => topic.value).toList(),
      );

      await blogLocalDataSource.upsertBlogs([blog]);

      return right(blog.toEntity());
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
  Stream<Either<Failure, BlogListSlice>> observeInitialBlogListSlice({
    required int limit,
  }) async* {
    BlogListSliceModel? cachedSlice;

    try {
      cachedSlice = await blogLocalDataSource.getFirstListSlice(
        limit: limit,
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);
      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in '
          'BlogRepositoryImpl.observeInitialBlogListSlice local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedSlice != null && cachedSlice.items.isNotEmpty) {
      yield right(
        BlogListSlice(
          blogs: cachedSlice.items.map((blog) => blog.toEntity()).toList(),
          source: BlogListSource.cache,
          nextCursor: cachedSlice.nextCursor,
        ),
      );
    }

    try {
      final remoteSlice = await blogRemoteDataSource.getBlogListSlice(
        limit: limit,
      );

      await blogLocalDataSource.upsertBlogs(remoteSlice.items);

      yield right(
        BlogListSlice(
          blogs: remoteSlice.items.map((blog) => blog.toEntity()).toList(),
          source: BlogListSource.remote,
          nextCursor: remoteSlice.nextCursor,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in '
          'BlogRepositoryImpl.observeInitialBlogListSlice remote fetch',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedSlice == null || cachedSlice.items.isEmpty) {
        yield left(failure);
      } else {
        yield right(
          BlogListSlice(
            blogs: cachedSlice.items.map((blog) => blog.toEntity()).toList(),
            source: BlogListSource.cache,
            nextCursor: cachedSlice.nextCursor,
            refreshFailure: failure,
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, BlogListSlice>> getBlogListSlice({
    required int limit,
    String? cursor,
  }) async {
    try {
      final remoteSlice = await blogRemoteDataSource.getBlogListSlice(
        limit: limit,
        cursor: cursor,
      );

      await blogLocalDataSource.upsertBlogs(remoteSlice.items);

      return right(
        BlogListSlice(
          blogs: remoteSlice.items.map((blog) => blog.toEntity()).toList(),
          source: BlogListSource.remote,
          nextCursor: remoteSlice.nextCursor,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogListSlice',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, Blog>> observeBlogById(String blogId) async* {
    BlogModel? cachedBlog;

    try {
      cachedBlog = await blogLocalDataSource.getBlogById(blogId);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.observeBlogById local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedBlog != null) {
      yield right(cachedBlog.toEntity());
    }

    try {
      final remoteBlog = await blogRemoteDataSource.getBlogById(blogId);
      await blogLocalDataSource.upsertBlogs([remoteBlog]);
      yield right(remoteBlog.toEntity());
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.observeBlogById',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedBlog == null) {
        yield left(failure);
      }
    }
  }

  @override
  Future<Either<Failure, File?>> getBlogImage(Blog blog) async {
    try {
      final imageFile = await imageFileCache.getOrDownload(
        cacheKey: blog.id,
        imageUrl: blog.imageUrl,
      );

      return right(imageFile);
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogImage',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }
}
