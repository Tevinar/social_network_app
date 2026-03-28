part of 'blog_editor_bloc.dart';

@immutable
sealed class BlogEditorEvent {}

final class AddBlog extends BlogEditorEvent {
  AddBlog({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;
}
