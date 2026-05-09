part of 'blog_list_bloc.dart';

/// Base state for the blog list screen.
@immutable
sealed class BlogListState {
  /// Creates a [BlogListState].
  const BlogListState({
    required this.blogs,
    required this.nextCursor,
    required this.isFromCache,
    required this.refreshError,
  });

  /// Blogs currently rendered in the list.
  final List<Blog> blogs;

  /// Remote cursor used to request the next list slice, when available.
  final String? nextCursor;

  /// Whether the latest emitted slice came from the local cache.
  final bool isFromCache;

  /// Refresh error kept alongside still-usable content, when applicable.
  final String? refreshError;
}

/// List state emitted while the screen is still loading content.
final class BlogListLoading extends BlogListState {
  /// Creates a [BlogListLoading].
  const BlogListLoading({
    required super.blogs,
    required super.nextCursor,
    required super.isFromCache,
    required super.refreshError,
  });
}

/// List state emitted when at least one list slice has been loaded.
final class BlogListSuccess extends BlogListState {
  /// Creates a [BlogListSuccess].
  const BlogListSuccess({
    required super.blogs,
    required super.nextCursor,
    required super.isFromCache,
    required super.refreshError,
  });
}

/// List state emitted when loading fails and no usable content is available.
final class BlogListFailure extends BlogListState {
  /// Creates a [BlogListFailure].
  const BlogListFailure({
    required this.error,
    required super.blogs,
    required super.nextCursor,
    required super.isFromCache,
    required super.refreshError,
  });

  /// Error shown to the user when the list could not be loaded.
  final String error;
}
