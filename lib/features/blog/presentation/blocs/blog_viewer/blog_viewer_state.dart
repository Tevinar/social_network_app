part of 'blog_viewer_bloc.dart';

/// The states of the [BlogViewerBloc].
sealed class BlogViewerState {
  const BlogViewerState();
}

/// The initial state of the [BlogViewerBloc] before any action is taken.
final class BlogViewerInitial extends BlogViewerState {}

/// The loading state of the [BlogViewerBloc] while a blog is being fetched.
final class BlogViewerLoading extends BlogViewerState {}

/// The success state of the [BlogViewerBloc] when a blog is successfully
/// loaded.
final class BlogViewerSuccess extends BlogViewerState {
  /// Creates a [BlogViewerSuccess] state with the loaded [blog] and optional
  /// locally cached image file.
  BlogViewerSuccess({
    required this.blog,
    required this.imageFile,
  });

  /// The loaded blog that can be displayed in the UI.
  final Blog blog;

  /// The locally cached or downloaded image file for [blog], when available.
  final File? imageFile;
}

/// The failure state of the [BlogViewerBloc] when an error occurs.
final class BlogViewerFailure extends BlogViewerState {
  /// Creates a [BlogViewerFailure] state with the given error message.
  BlogViewerFailure({required this.error});

  /// The error message describing the failure.
  final String error;
}
