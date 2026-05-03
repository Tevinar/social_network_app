part of 'blog_feed_bloc.dart';

/// Base state for the blog feed screen.
@immutable
sealed class BlogFeedState {
  /// Creates a [BlogFeedState].
  const BlogFeedState({
    required this.blogs,
    required this.nextCursor,
    required this.hasNewContentAvailable,
    required this.isLoadingMore,
    required this.isFromCache,
    required this.refreshError,
  });

  /// Blogs currently rendered in the feed.
  final List<Blog> blogs;

  /// Remote cursor used to request the next feed slice, when available.
  final String? nextCursor;

  /// Whether the backend reported newer content above the current list.
  final bool hasNewContentAvailable;

  /// Whether a pagination request is currently running.
  final bool isLoadingMore;

  /// Whether the latest emitted slice came from the local cache.
  final bool isFromCache;

  /// Refresh error kept alongside still-usable content, when applicable.
  final String? refreshError;

  /// Returns a copy of this state with the provided fields replaced.
  BlogFeedState copyWith({
    List<Blog>? blogs,
    Object? nextCursor = _sentinel,
    bool? hasNewContentAvailable,
    bool? isLoadingMore,
    bool? isFromCache,
    Object? refreshError = _sentinel,
  }) {
    return switch (this) {
      BlogFeedLoading() => BlogFeedLoading(
        blogs: blogs ?? this.blogs,
        nextCursor: nextCursor == _sentinel
            ? this.nextCursor
            : nextCursor as String?,
        hasNewContentAvailable:
            hasNewContentAvailable ?? this.hasNewContentAvailable,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isFromCache: isFromCache ?? this.isFromCache,
        refreshError: refreshError == _sentinel
            ? this.refreshError
            : refreshError as String?,
      ),
      BlogFeedSuccess() => BlogFeedSuccess(
        blogs: blogs ?? this.blogs,
        nextCursor: nextCursor == _sentinel
            ? this.nextCursor
            : nextCursor as String?,
        hasNewContentAvailable:
            hasNewContentAvailable ?? this.hasNewContentAvailable,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isFromCache: isFromCache ?? this.isFromCache,
        refreshError: refreshError == _sentinel
            ? this.refreshError
            : refreshError as String?,
      ),
      BlogFeedFailure(:final error) => BlogFeedFailure(
        error: error,
        blogs: blogs ?? this.blogs,
        nextCursor: nextCursor == _sentinel
            ? this.nextCursor
            : nextCursor as String?,
        hasNewContentAvailable:
            hasNewContentAvailable ?? this.hasNewContentAvailable,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isFromCache: isFromCache ?? this.isFromCache,
        refreshError: refreshError == _sentinel
            ? this.refreshError
            : refreshError as String?,
      ),
    };
  }
}

/// Feed state emitted while the screen is still loading content.
final class BlogFeedLoading extends BlogFeedState {
  /// Creates a [BlogFeedLoading].
  const BlogFeedLoading({
    required super.blogs,
    required super.nextCursor,
    required super.hasNewContentAvailable,
    required super.isLoadingMore,
    required super.isFromCache,
    required super.refreshError,
  });
}

/// Feed state emitted when at least one feed slice has been loaded.
final class BlogFeedSuccess extends BlogFeedState {
  /// Creates a [BlogFeedSuccess].
  const BlogFeedSuccess({
    required super.blogs,
    required super.nextCursor,
    required super.hasNewContentAvailable,
    required super.isLoadingMore,
    required super.isFromCache,
    required super.refreshError,
  });
}

/// Feed state emitted when loading fails and no usable content is available.
final class BlogFeedFailure extends BlogFeedState {
  /// Creates a [BlogFeedFailure].
  const BlogFeedFailure({
    required this.error,
    required super.blogs,
    required super.nextCursor,
    required super.hasNewContentAvailable,
    required super.isLoadingMore,
    required super.isFromCache,
    required super.refreshError,
  });

  /// Error shown to the user when the feed could not be loaded.
  final String error;
}

const _sentinel = Object();
