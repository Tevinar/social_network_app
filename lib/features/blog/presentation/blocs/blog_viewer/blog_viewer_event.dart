part of 'blog_viewer_bloc.dart';

/// The events of the [BlogViewerBloc].
sealed class BlogViewerEvent {
  const BlogViewerEvent();
}

/// An event to load a blog by its ID,
class LoadBlog extends BlogViewerEvent {
  /// Creates a [LoadBlog] event.
  LoadBlog({required this.blogId});

  /// The blog ID to load.
  final String blogId;
}
