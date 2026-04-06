part of 'blog_viewer_bloc.dart';

/// The events of the [BlogViewerBloc].
sealed class BlogViewerEvent {
  const BlogViewerEvent();
}

/// An event to load a blog by its ID,
/// optionally using a list of blogs for caching.
class LoadBlog extends BlogViewerEvent {
  /// Creates a [LoadBlog] event.
  LoadBlog({this.blogId, this.blogs});

  /// The blog ID to load.
  final String? blogId;

  /// An optional list of blogs to check for a cached version before fetching.
  final List<Blog>? blogs;
}
