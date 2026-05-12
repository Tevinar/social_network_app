part of 'blog_editor_bloc.dart';

/// Base state emitted by [BlogEditorBloc].
@immutable
sealed class BlogEditorState {
  /// Creates a [BlogEditorState].
  const BlogEditorState();
}

/// Initial idle state before any upload attempt starts.
final class BlogInitial extends BlogEditorState {
  /// Creates a [BlogInitial].
  const BlogInitial();
}

/// State emitted while a blog upload request is in progress.
final class BlogLoading extends BlogEditorState {
  /// Creates a [BlogLoading].
  const BlogLoading();
}

/// State emitted after a blog is uploaded successfully.
final class BlogUploadSuccess extends BlogEditorState {
  /// Creates a [BlogUploadSuccess].
  const BlogUploadSuccess(this.blog);

  /// Uploaded blog returned by the backend.
  final Blog blog;
}

/// State emitted when the upload request fails.
final class BlogFailure extends BlogEditorState {
  /// Creates a [BlogFailure].
  const BlogFailure(this.error);

  /// Human-readable error message.
  final String error;
}
