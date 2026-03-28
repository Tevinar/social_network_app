part of 'blog_editor_bloc.dart';

@immutable
/// Represents blog editor state.
sealed class BlogEditorState {}

/// A blog initial.
final class BlogInitial extends BlogEditorState {}

/// A blog loading.
final class BlogLoading extends BlogEditorState {}

/// A blog upload success.
final class BlogUploadSuccess extends BlogEditorState {}

/// Represents blog failure.
final class BlogFailure extends BlogEditorState {
  /// Creates a [BlogFailure].
  BlogFailure(this.error);

  /// The error.
  final String error;
}
