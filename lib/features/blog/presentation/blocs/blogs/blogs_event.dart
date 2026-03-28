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

/// A refresh blogs view.
class RefreshBlogsView extends BlogsEvent {}
