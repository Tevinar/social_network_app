part of 'chat_message_list_bloc.dart';

@immutable
/// Represents chat message list state.
sealed class ChatMessageListState {
  /// Creates a [ChatMessageListState].
  const ChatMessageListState({
    required this.chatId,
    required this.chatMessages,
    required this.nextCursor,
  });

  /// Identifier of the currently loaded chat.
  final String chatId;

  /// Messages currently rendered for the chat.
  final List<ChatMessage> chatMessages;

  /// Opaque cursor used to request the next slice, when available.
  final String? nextCursor;

  /// Returns a new state of the same subtype with updated message-list data.
  ChatMessageListState copyWith({
    String? chatId,
    List<ChatMessage>? chatMessages,
    String? nextCursor,
  }) {
    return switch (this) {
      ChatMessageListLoading() => ChatMessageListLoading(
        chatId: chatId ?? this.chatId,
        chatMessages: chatMessages ?? this.chatMessages,
        nextCursor: nextCursor ?? this.nextCursor,
      ),
      ChatMessageListSuccess() => ChatMessageListSuccess(
        chatId: chatId ?? this.chatId,
        chatMessages: chatMessages ?? this.chatMessages,
        nextCursor: nextCursor ?? this.nextCursor,
      ),
      ChatMessageListFailure(:final error) => ChatMessageListFailure(
        chatId: chatId ?? this.chatId,
        error: error,
        chatMessages: chatMessages ?? this.chatMessages,
        nextCursor: nextCursor ?? this.nextCursor,
      ),
    };
  }
}

/// State emitted while the message list is loading.
final class ChatMessageListLoading extends ChatMessageListState {
  /// Creates a [ChatMessageListLoading].
  const ChatMessageListLoading({
    required super.chatId,
    required super.chatMessages,
    required super.nextCursor,
  });
}

/// State emitted when at least one message slice has been loaded.
final class ChatMessageListSuccess extends ChatMessageListState {
  /// Creates a [ChatMessageListSuccess].
  const ChatMessageListSuccess({
    required super.chatId,
    required super.chatMessages,
    required super.nextCursor,
  });
}

/// State emitted when loading or sending chat messages fails.
final class ChatMessageListFailure extends ChatMessageListState {
  /// Creates a [ChatMessageListFailure].
  const ChatMessageListFailure({
    required super.chatId,
    required this.error,
    required super.chatMessages,
    required super.nextCursor,
  });

  /// Error shown to the user when the message list action fails.
  final String error;
}
