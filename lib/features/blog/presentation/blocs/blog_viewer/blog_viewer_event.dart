part of 'blog_viewer_bloc.dart';

/// The events of the [BlogViewerBloc].
sealed class BlogViewerEvent {
  const BlogViewerEvent();
}

/// An event to load a blog by its ID.
class LoadBlog extends BlogViewerEvent {
  /// Creates a [LoadBlog] event.
  LoadBlog({required this.blogId});

  /// The stable blog ID to load.
  ///
  /// The viewer is keyed by this primitive identifier so it can be restored
  /// from deep links and push notifications instead of depending on a
  /// previously passed blog object.
  final String blogId;
}

final class _BlogReceived extends BlogViewerEvent {
  const _BlogReceived(this.result);

  final Either<Failure, Blog> result;
}
