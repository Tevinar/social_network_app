import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

/// A snapshot of a single blogs page load.
class BlogsPageSnapshot {
  /// Creates a [BlogsPageSnapshot].
  const BlogsPageSnapshot({
    required this.pageNumber,
    required this.blogs,
    required this.source,
    this.refreshFailure,
  });

  /// The page number this snapshot belongs to.
  final int pageNumber;

  /// The blogs available for that page.
  final List<Blog> blogs;

  /// The origin of the emitted page data.
  final BlogsPageSource source;

  /// The remote refresh failure when stale cache is still being shown.
  final Failure? refreshFailure;
}

/// The origin of a blogs page snapshot.
enum BlogsPageSource {
  /// Data came from local cache.
  cache,

  /// Data came from the remote source.
  remote,
}
