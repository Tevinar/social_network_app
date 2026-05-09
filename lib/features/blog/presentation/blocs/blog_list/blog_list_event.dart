part of 'blog_list_bloc.dart';

/// Base class for all events handled by [BlogListBloc].
@immutable
sealed class BlogListEvent {
  /// Creates a [BlogListEvent].
  const BlogListEvent();
}

/// Requests the initial list slice.
final class LoadInitialList extends BlogListEvent {
  /// Creates a [LoadInitialList].
  const LoadInitialList();
}

/// Requests the next list slice using the current cursor.
final class LoadMoreList extends BlogListEvent {
  /// Creates a [LoadMoreList].
  const LoadMoreList();
}

/// Requests a refresh of the first list slice.
final class RefreshList extends BlogListEvent {
  /// Creates a [RefreshList].
  const RefreshList();
}

/// Prepends a newly created blog to the top of the currently visible list.
final class PrependCreatedBlog extends BlogListEvent {
  /// Creates a [PrependCreatedBlog].
  const PrependCreatedBlog(this.blog);

  /// Blog created successfully by the backend.
  final Blog blog;
}

final class _InitialListSliceReceived extends BlogListEvent {
  const _InitialListSliceReceived(this.result);

  final Either<Failure, BlogListSlice> result;
}
