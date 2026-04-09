import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';

/// A cache-first snapshot of a single blog load.
class BlogSnapshot {
  /// Creates a [BlogSnapshot].
  const BlogSnapshot({
    required this.blog,
    required this.source,
    this.refreshFailure,
  });

  /// The blog that can currently be displayed.
  final Blog blog;

  /// The origin of the displayed blog data.
  final BlogSource source;

  /// The remote refresh failure when stale cached data is still available.
  final Failure? refreshFailure;
}

/// The origin of a [BlogSnapshot].
enum BlogSource {
  /// The blog came from local cache.
  cache,

  /// The blog came from the remote source.
  remote,
}
