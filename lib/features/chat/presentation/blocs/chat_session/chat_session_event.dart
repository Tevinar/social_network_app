part of 'chat_session_bloc.dart';

@immutable
/// Base type for all chat-session events.
sealed class ChatSessionEvent {}

/// Requests resolving an existing chat or starting a new one.
class AddChat extends ChatSessionEvent {
  /// Creates an [AddChat].
  AddChat({required this.chatMembers});

  /// Members to include in the new chat
  final List<ChatUserSummary> chatMembers;
}

/// Requests creation of the first message for a new chat session.
class AddChatFirstMessage extends ChatSessionEvent {
  /// Creates an [AddChatFirstMessage].
  AddChatFirstMessage({required this.firstMessageContent});

  /// Content of the first message to send.
  final String firstMessageContent;
}

/// Selects an existing chat session and marks it ready to open.
class SelectChat extends ChatSessionEvent {
  /// Creates a [SelectChat].
  SelectChat({required this.chatId, required this.chatMembers});

  /// Identifier of the selected chat session.
  final String chatId;

  /// The users belonging to the selected chat session.
  final List<ChatUserSummary> chatMembers;
}
