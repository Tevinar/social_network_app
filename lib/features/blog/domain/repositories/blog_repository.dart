import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/read_models/blog_list_slice.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

/// Domain repository contract for blog creation, reading, and list slices.
abstract interface class BlogRepository {
  /// Creates a new blog and returns the persisted domain entity.
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required List<BlogTopic> topics,
  });

  /// Observes a cache-first snapshot of the initial blog list slice and then
  /// refreshes that same slice once from the remote source.
  Stream<Either<Failure, BlogListSlice>> observeInitialBlogListSlice({
    required int limit,
  });

  /// Loads one cursor-based blog list slice from the remote source.
  Future<Either<Failure, BlogListSlice>> getBlogListSlice({
    required int limit,
    String? cursor,
  });

  /// Observes a cache-first snapshot of the blog and then refreshes that same
  /// blog once from the remote source.
  ///
  /// The viewer route stays keyed by [blogId] instead of receiving a full
  /// [Blog] object so it can also be opened from deep links and push
  /// notifications, where only the identifier is reliably available. This
  /// cache-first observation restores the same fast-first-render behavior that
  /// passing a full blog object would provide without weakening the route
  /// contract.
  Stream<Either<Failure, Blog>> observeBlogById(String blogId);

  /// Retrieves the locally cached or downloaded image file for [blog].
  Future<Either<Failure, File?>> getBlogImage(Blog blog);
}
