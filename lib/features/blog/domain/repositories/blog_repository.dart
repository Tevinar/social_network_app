import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/events/blog_feed_event.dart';
import 'package:social_app/features/blog/domain/read_models/blog_feed_slice.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

/// Domain repository contract for blog creation, reading, feed slices, and
/// feed event subscriptions.
abstract interface class BlogRepository {
  /// Creates a new blog and returns the persisted domain entity.
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required List<BlogTopic> topics,
  });

  /// Emits a cache-first feed slice snapshot and then refreshes it from the
  /// remote source.
  Stream<Either<Failure, BlogFeedSlice>> watchBlogFeedSlice({
    required int limit,
    String? cursor,
  });

  /// Opens a live stream of blog feed events emitted by the backend.
  Stream<Either<Failure, BlogFeedEvent>> watchBlogFeedEvents();

  /// Retrieves a single blog by its stable identifier.
  Future<Either<Failure, Blog>> getBlogById(String blogId);
}
