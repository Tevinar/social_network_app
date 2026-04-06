part of 'blog_viewer_bloc.dart';

sealed class BlogViewerState {
  const BlogViewerState();
}

final class BlogViewerInitial extends BlogViewerState {}

final class BlogViewerLoading extends BlogViewerState {}

final class BlogViewerSuccess extends BlogViewerState {
  final Blog blog;

  BlogViewerSuccess({required this.blog});
}

final class BlogViewerFailure extends BlogViewerState {
  final String error;

  BlogViewerFailure({required this.error});
}
