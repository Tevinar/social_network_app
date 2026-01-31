part of 'blogs_bloc.dart';

@immutable
sealed class BlogsEvent {}

final class LoadBlogsNextPage extends BlogsEvent {}

final class BlogChangeReceived extends BlogsEvent {
  final Either<Failure, BlogChange> blogChange;
  BlogChangeReceived(this.blogChange);
}
