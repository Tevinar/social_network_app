part of 'chat_messages_bloc.dart';

@immutable
/// Represents chat messages state.
sealed class ChatMessagesState {
  const ChatMessagesState({
    required this.chatId,
    required this.chatMessages,
    required this.pageNumber,
    this.totalChatMessagesInDatabase,
  });

  /// The chat id.
  final String chatId;

  /// The chat messages.
  final List<ChatMessage> chatMessages;

  /// The int.
  final int pageNumber;

  /// The int.
  final int? totalChatMessagesInDatabase;

  /// The copy with.
  ChatMessagesState copyWith({
    /// The chat id.
    String? chatId,

    /// The chat messages.
    List<ChatMessage>? chatMessages,
    int? pageNumber,
    int? totalChatMessagesInDatabase,
  }) {
    return switch (this) {
      ChatMessagesLoading() => ChatMessagesLoading(
        chatId: chatId ?? this.chatId,
        chatMessages: chatMessages ?? this.chatMessages,
        pageNumber: pageNumber ?? this.pageNumber,
        totalChatMessagesInDatabase:
            totalChatMessagesInDatabase ?? this.totalChatMessagesInDatabase,
      ),

      ChatMessagesSuccess() => ChatMessagesSuccess(
        chatId: chatId ?? this.chatId,
        chatMessages: chatMessages ?? this.chatMessages,
        pageNumber: pageNumber ?? this.pageNumber,
        totalChatMessagesInDatabase:
            totalChatMessagesInDatabase ?? this.totalChatMessagesInDatabase,
      ),

      ChatMessagesFailure(:final error) => ChatMessagesFailure(
        chatId: chatId ?? this.chatId,
        error: error,
        chatMessages: chatMessages ?? this.chatMessages,
        pageNumber: pageNumber ?? this.pageNumber,
        totalChatMessagesInDatabase:
            totalChatMessagesInDatabase ?? this.totalChatMessagesInDatabase,
      ),
    };
  }
}

/// A chat messages loading.
final class ChatMessagesLoading extends ChatMessagesState {
  /// Creates a [ChatMessagesLoading].
  const ChatMessagesLoading({
    required super.chatId,
    required super.chatMessages,
    required super.pageNumber,
    super.totalChatMessagesInDatabase,
  });
}

/// A chat messages success.
final class ChatMessagesSuccess extends ChatMessagesState {
  /// Creates a [ChatMessagesSuccess].
  const ChatMessagesSuccess({
    required super.chatId,
    required super.chatMessages,
    required super.pageNumber,
    super.totalChatMessagesInDatabase,
  });
}

/// Represents chat messages failure.
final class ChatMessagesFailure extends ChatMessagesState {
  /// Creates a [ChatMessagesFailure].
  const ChatMessagesFailure({
    required super.chatId,
    required this.error,
    required super.chatMessages,
    required super.pageNumber,
    super.totalChatMessagesInDatabase,
  });

  /// The error.
  final String error;
}
