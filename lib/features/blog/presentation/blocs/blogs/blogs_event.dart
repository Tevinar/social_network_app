part of 'blogs_bloc.dart';

@immutable
sealed class BlogsEvent {}

final class LoadBlogsNextPage extends BlogsEvent {}
