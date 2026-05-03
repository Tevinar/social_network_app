part of 'blog_editor_bloc.dart';

@immutable
sealed class BlogEditorState {}

final class BlogInitial extends BlogEditorState {}

final class BlogLoading extends BlogEditorState {}

final class BlogUploadSuccess extends BlogEditorState {
  final Blog blog;

  BlogUploadSuccess(this.blog);
}

final class BlogFailure extends BlogEditorState {
  BlogFailure(this.error);

  /// The error.
  final String error;
}
