part of 'blogs_bloc.dart';

@immutable
sealed class BlogsEvent {}

final class LoadBlogsNextPage extends BlogsEvent {}

final class BlogChangeReceived extends BlogsEvent {
  BlogChangeReceived(this.blogChange);
  final Either<Failure, BlogChange> blogChange;
}

class RefreshBlogsView extends BlogsEvent {}
