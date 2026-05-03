part of 'blog_editor_bloc.dart';

@immutable
/// Represents blog editor event.
sealed class BlogEditorEvent {}

/// An add blog.
final class AddBlog extends BlogEditorEvent {
  /// Creates a [AddBlog].
  AddBlog({
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });

  /// The title.
  final String title;

  /// The content.
  final String content;

  /// The image.
  final File image;

  /// The topics.
  final List<BlogTopic> topics;
}
