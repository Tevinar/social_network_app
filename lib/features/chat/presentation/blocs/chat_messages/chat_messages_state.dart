part of 'chat_messages_bloc.dart';

@immutable
sealed class ChatMessagesState {
  final String chatId;
  final List<ChatMessage> chatMessages;
  final int pageNumber;
  final int? totalChatMessagesInDatabase;

  const ChatMessagesState({
    required this.chatId,
    required this.chatMessages,
    required this.pageNumber,
    this.totalChatMessagesInDatabase,
  });

  ChatMessagesState copyWith({
    String? chatId,
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

final class ChatMessagesLoading extends ChatMessagesState {
  const ChatMessagesLoading({
    required super.chatId,
    required super.chatMessages,
    required super.pageNumber,
    super.totalChatMessagesInDatabase,
  });
}

final class ChatMessagesSuccess extends ChatMessagesState {
  const ChatMessagesSuccess({
    required super.chatId,
    required super.chatMessages,
    required super.pageNumber,
    super.totalChatMessagesInDatabase,
  });
}

final class ChatMessagesFailure extends ChatMessagesState {
  final String error;

  const ChatMessagesFailure({
    required super.chatId,
    required this.error,
    required super.chatMessages,
    required super.pageNumber,
    super.totalChatMessagesInDatabase,
  });
}
