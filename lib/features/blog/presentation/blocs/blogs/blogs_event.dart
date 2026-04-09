part of 'blogs_bloc.dart';

@immutable
/// Represents blogs event.
sealed class BlogsEvent {}

/// A load blogs next page widget.
final class LoadBlogsNextPage extends BlogsEvent {}

/// A blog change received.
final class BlogChangeReceived extends BlogsEvent {
  /// Creates a [BlogChangeReceived].
  BlogChangeReceived(this.blogChange);

  /// The blog change.
  final Either<Failure, BlogChange> blogChange;
}

/// A blogs page snapshot received from the cache-first stream.
final class _BlogsPageSnapshotReceived extends BlogsEvent {
  /// Creates a [_BlogsPageSnapshotReceived].
  _BlogsPageSnapshotReceived(this.pageNumber, this.result);

  /// The page that emitted.
  final int pageNumber;

  /// The emitted repository result for that page.
  final Either<Failure, BlogsPageSnapshot> result;
}

/// A refresh blogs view.
class RefreshBlogsView extends BlogsEvent {}
