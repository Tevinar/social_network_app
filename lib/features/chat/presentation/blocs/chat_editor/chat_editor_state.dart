part of 'chat_editor_bloc.dart';

@immutable
/// Represents chat editor state.
sealed class ChatEditorState {
  const ChatEditorState({required this.chatMembers});

  /// The chat members.
  final List<UserEntity> chatMembers;
}

/// A chat editor drafted.
final class ChatEditorDrafted extends ChatEditorState {
  /// Creates a [ChatEditorDrafted].
  const ChatEditorDrafted({required super.chatMembers});
}

/// A chat editor loaded.
final class ChatEditorLoaded extends ChatEditorState {
  /// Creates a [ChatEditorLoaded].
  const ChatEditorLoaded({required super.chatMembers, required this.chatId});

  /// The chat id.
  final String chatId;
}

/// A chat editor loading.
final class ChatEditorLoading extends ChatEditorState {
  /// Creates a [ChatEditorLoading].
  const ChatEditorLoading({required super.chatMembers});
}

/// A chat editor waiting for first message.
final class ChatEditorWaitingForFirstMessage extends ChatEditorState {
  /// Creates a [ChatEditorWaitingForFirstMessage].
  const ChatEditorWaitingForFirstMessage({required super.chatMembers});
}

/// Represents chat editor failure.
final class ChatEditorFailure extends ChatEditorState {
  /// Creates a [ChatEditorFailure].
  const ChatEditorFailure(this.message, {required super.chatMembers});

  /// The message.
  final String message;
}
