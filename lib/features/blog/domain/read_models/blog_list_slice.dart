import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

/// Cache-first snapshot of one blog list slice.
class BlogListSlice {
  /// Creates a [BlogListSlice].
  const BlogListSlice({
    required this.blogs,
    required this.source,
    required this.nextCursor,
    this.refreshFailure,
  });

  /// Blogs currently available for the requested list slice.
  final List<Blog> blogs;

  /// Origin of the currently emitted list slice.
  final BlogListSource source;

  /// Opaque remote cursor used to request the next list slice, when available.
  final String? nextCursor;

  /// Remote refresh failure when cached content is still available.
  final Failure? refreshFailure;
}

/// Origin of a [BlogListSlice].
enum BlogListSource {
  /// List slice emitted from the local cache.
  cache,

  /// List slice emitted from the remote backend.
  remote,
}
