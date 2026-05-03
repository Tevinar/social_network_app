import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

/// Cache-first snapshot of one blog feed slice.
class BlogFeedSlice {
  /// Creates a [BlogFeedSlice].
  const BlogFeedSlice({
    required this.blogs,
    required this.source,
    required this.nextCursor,
    this.refreshFailure,
  });

  /// Blogs currently available for the requested feed slice.
  final List<Blog> blogs;

  /// Origin of the currently emitted feed slice.
  final BlogFeedSource source;

  /// Opaque remote cursor used to request the next feed slice, when available.
  final String? nextCursor;

  /// Remote refresh failure when cached content is still available.
  final Failure? refreshFailure;
}

/// Origin of a [BlogFeedSlice].
enum BlogFeedSource {
  /// Feed slice emitted from the local cache.
  cache,

  /// Feed slice emitted from the remote backend.
  remote,
}
