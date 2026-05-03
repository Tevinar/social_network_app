part of 'blog_feed_bloc.dart';

/// Base class for all events handled by [BlogFeedBloc].
@immutable
sealed class BlogFeedBlocEvent {
  /// Creates a [BlogFeedBlocEvent].
  const BlogFeedBlocEvent();
}

/// Requests the initial feed slice.
final class LoadInitialFeed extends BlogFeedBlocEvent {
  /// Creates a [LoadInitialFeed].
  const LoadInitialFeed();
}

/// Requests the next feed slice using the current cursor.
final class LoadMoreFeed extends BlogFeedBlocEvent {
  /// Creates a [LoadMoreFeed].
  const LoadMoreFeed();
}

/// Requests a refresh of the first feed slice.
final class RefreshFeed extends BlogFeedBlocEvent {
  /// Creates a [RefreshFeed].
  const RefreshFeed();
}

/// Prepends a newly created blog to the top of the currently visible feed.
final class PrependCreatedBlog extends BlogFeedBlocEvent {
  /// Creates a [PrependCreatedBlog].
  const PrependCreatedBlog(this.blog);

  /// Blog created successfully by the backend.
  final Blog blog;
}

final class _FeedSliceReceived extends BlogFeedBlocEvent {
  const _FeedSliceReceived({
    required this.result,
    required this.isFirstSlice,
  });

  final Either<Failure, BlogFeedSlice> result;
  final bool isFirstSlice;
}

final class _FeedEventReceived extends BlogFeedBlocEvent {
  const _FeedEventReceived(this.result);

  final Either<Failure, BlogFeedEvent> result;
}
