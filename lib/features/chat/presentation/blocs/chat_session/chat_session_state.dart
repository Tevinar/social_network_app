part of 'chat_session_bloc.dart';

@immutable
/// Represents the lifecycle state of one chat session.
sealed class ChatSessionState {
  const ChatSessionState({required this.chatMembers});

  /// Members participating in the session.
  final List<ChatUserSummary> chatMembers;
}

/// Initial state before a chat has been resolved or created.
final class ChatSessionDrafted extends ChatSessionState {
  /// Creates a [ChatSessionDrafted].
  const ChatSessionDrafted({required super.chatMembers});
}

/// State for an existing chat session that is ready to open.
final class ChatSessionLoaded extends ChatSessionState {
  /// Creates a [ChatSessionLoaded].
  const ChatSessionLoaded({required super.chatMembers, required this.chatId});

  /// Identifier of the ready chat session.
  final String chatId;
}

/// State for an existing chat session that is ready to open.
final class ChatSessionNewlyCreated extends ChatSessionState {
  /// Creates a [ChatSessionNewlyCreated].
  const ChatSessionNewlyCreated({
    required super.chatMembers,
    required this.chatFirstMessage,
    required this.chatId,
  });

  /// Identifier of the ready chat session.
  final String chatId;

  /// The first message sent in the newly created chat session.
  final ChatMessage chatFirstMessage;
}

/// State while resolving or creating a chat session.
final class ChatSessionLoading extends ChatSessionState {
  /// Creates a [ChatSessionLoading].
  const ChatSessionLoading({required super.chatMembers});
}

/// State when no chat exists yet and the first message is still required.
final class ChatSessionWaitingForFirstMessage extends ChatSessionState {
  /// Creates a [ChatSessionWaitingForFirstMessage].
  const ChatSessionWaitingForFirstMessage({required super.chatMembers});
}

/// State for a failed chat-session action.
final class ChatSessionFailure extends ChatSessionState {
  /// Creates a [ChatSessionFailure].
  const ChatSessionFailure(this.message, {required super.chatMembers});

  /// Failure message describing what went wrong.
  final String message;
}
