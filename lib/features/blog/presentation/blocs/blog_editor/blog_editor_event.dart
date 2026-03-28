part of 'blog_editor_bloc.dart';

@immutable
/// Represents blog editor event.
sealed class BlogEditorEvent {}

/// An add blog.
final class AddBlog extends BlogEditorEvent {
  /// Creates a [AddBlog].
  AddBlog({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });

  /// The poster id.
  final String posterId;

  /// The title.
  final String title;

  /// The content.
  final String content;

  /// The image.
  final File image;

  /// The topics.
  final List<String> topics;
}
