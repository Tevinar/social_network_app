import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_local_data_source.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_feed_event_model.dart';
import 'package:social_app/features/blog/data/models/blog_feed_slice_model.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/events/blog_feed_event.dart';
import 'package:social_app/features/blog/domain/read_models/blog_feed_slice.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Repository implementation that composes blog local and remote data sources
/// into cache-first domain operations.
class BlogRepositoryImpl implements BlogRepository {
  /// Creates a [BlogRepositoryImpl].
  BlogRepositoryImpl({
    required this.blogRemoteDataSource,
    required this.blogLocalDataSource,
  });

  /// Remote data source used for backend blog operations and feed events.
  final BlogRemoteDataSource blogRemoteDataSource;

  /// Local data source used for caching the first feed slice and individual
  /// blog records.
  final BlogLocalDataSource blogLocalDataSource;

  @override
  /// Creates a blog remotely, updates the local cache, and returns the
  /// resulting domain entity.
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
  /// Emits the cached first feed slice when available and then refreshes the
  /// same slice from the remote source.
  Stream<Either<Failure, BlogFeedSlice>> watchBlogFeedSlice({
    required int limit,
    String? cursor,
  }) async* {
    BlogFeedSliceModel? cachedSlice;

    try {
      cachedSlice = await blogLocalDataSource.getFirstFeedSlice(
        limit: limit,
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);
      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchFeedSlice local read',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    if (cachedSlice != null && cachedSlice.items.isNotEmpty) {
      yield right(
        BlogFeedSlice(
          blogs: cachedSlice.items.map((blog) => blog.toEntity()).toList(),
          source: BlogFeedSource.cache,
          nextCursor: cachedSlice.nextCursor,
        ),
      );
    }

    try {
      final remoteSlice = await blogRemoteDataSource.getBlogFeedSlice(
        limit: limit,
        cursor: cursor,
      );

      await blogLocalDataSource.upsertBlogs(remoteSlice.items);

      yield right(
        BlogFeedSlice(
          blogs: remoteSlice.items.map((blog) => blog.toEntity()).toList(),
          source: BlogFeedSource.remote,
          nextCursor: remoteSlice.nextCursor,
        ),
      );
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchFeedSlice remote fetch',
          error: error,
          stackTrace: stackTrace,
        );
      }

      if (cachedSlice == null || cachedSlice.items.isEmpty) {
        yield left(failure);
      } else {
        yield right(
          BlogFeedSlice(
            blogs: cachedSlice.items.map((blog) => blog.toEntity()).toList(),
            source: BlogFeedSource.cache,
            nextCursor: cachedSlice.nextCursor,
            refreshFailure: failure,
          ),
        );
      }
    }
  }

  @override
  /// Streams live backend blog feed events mapped into domain event objects.
  Stream<Either<Failure, BlogFeedEvent>> watchBlogFeedEvents() async* {
    try {
      await for (final BlogFeedEventModel event
          in blogRemoteDataSource.watchBlogFeedEvents()) {
        yield right(
          BlogFeedEvent(
            type: BlogFeedEventType.fromValue(event.type),
            blogId: event.blogId,
          ),
        );
      }
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchFeedEvents',
          error: error,
          stackTrace: stackTrace,
        );
      }

      yield left(failure);
    }
  }

  @override
  /// Returns one blog by id, preferring a fresh remote value and falling back
  /// to cache when needed.
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
      final remoteBlog = await blogRemoteDataSource.getBlogById(blogId);
      await blogLocalDataSource.upsertBlogs([remoteBlog]);
      return right(remoteBlog.toEntity());
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
