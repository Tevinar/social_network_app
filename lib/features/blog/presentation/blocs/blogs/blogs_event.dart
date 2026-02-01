part of 'blogs_bloc.dart';

@immutable
sealed class BlogsEvent {}

final class LoadBlogsNextPage extends BlogsEvent {}

final class BlogChangeReceived extends BlogsEvent {
  final Either<ServerFailure, BlogChange> blogChange;
  BlogChangeReceived(this.blogChange);
}

class RefreshBlogsView extends BlogsEvent {}
