import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_messages/chat_messages_bloc.dart';

void main() {
  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  test(
    'given ChatMessagesLoading when copyWith is called then returns '
    'ChatMessagesLoading with updated values',
    () {
      // Arrange
      const state = ChatMessagesLoading(
        chatId: 'chat-1',
        chatMessages: [],
        pageNumber: 1,
      );

      // Act
      final result = state.copyWith(
        chatId: 'chat-2',
        chatMessages: [message],
        pageNumber: 2,
        totalChatMessagesInDatabase: 4,
      );

      // Assert
      expect(result, isA<ChatMessagesLoading>());
      expect(result.chatId, 'chat-2');
      expect(result.chatMessages, [message]);
      expect(result.pageNumber, 2);
      expect(result.totalChatMessagesInDatabase, 4);
    },
  );

  test(
    'given ChatMessagesLoading when copyWith omits messages and total count '
    'then it preserves existing values',
    () {
      // Arrange
      final state = ChatMessagesLoading(
        chatId: 'chat-1',
        chatMessages: [message],
        pageNumber: 1,
        totalChatMessagesInDatabase: 4,
      );

      // Act
      final result = state.copyWith(chatId: 'chat-2', pageNumber: 2);

      // Assert
      expect(result, isA<ChatMessagesLoading>());
      expect(result.chatId, 'chat-2');
      expect(result.chatMessages, [message]);
      expect(result.pageNumber, 2);
      expect(result.totalChatMessagesInDatabase, 4);
    },
  );

  test(
    'given ChatMessagesSuccess when copyWith is called then returns '
    'ChatMessagesSuccess with updated values',
    () {
      // Arrange
      const state = ChatMessagesSuccess(
        chatId: 'chat-1',
        chatMessages: [],
        pageNumber: 1,
      );

      // Act
      final result = state.copyWith(
        chatId: 'chat-2',
        chatMessages: [message],
        pageNumber: 2,
        totalChatMessagesInDatabase: 4,
      );

      // Assert
      expect(result, isA<ChatMessagesSuccess>());
      expect(result.chatId, 'chat-2');
      expect(result.chatMessages, [message]);
      expect(result.pageNumber, 2);
      expect(result.totalChatMessagesInDatabase, 4);
    },
  );

  test(
    'given ChatMessagesSuccess when copyWith omits messages then it '
    'preserves existing values',
    () {
      // Arrange
      final state = ChatMessagesSuccess(
        chatId: 'chat-1',
        chatMessages: [message],
        pageNumber: 1,
        totalChatMessagesInDatabase: 4,
      );

      // Act
      final result = state.copyWith(chatId: 'chat-2', pageNumber: 2);

      // Assert
      expect(result, isA<ChatMessagesSuccess>());
      expect(result.chatId, 'chat-2');
      expect(result.chatMessages, [message]);
      expect(result.pageNumber, 2);
      expect(result.totalChatMessagesInDatabase, 4);
    },
  );

  test(
    'given ChatMessagesFailure when copyWith is called then preserves the '
    'error and updates other values',
    () {
      // Arrange
      const state = ChatMessagesFailure(
        chatId: 'chat-1',
        error: 'boom',
        chatMessages: [],
        pageNumber: 1,
      );

      // Act
      final result = state.copyWith(
        chatId: 'chat-2',
        chatMessages: [message],
        pageNumber: 2,
        totalChatMessagesInDatabase: 4,
      );

      // Assert
      expect(result, isA<ChatMessagesFailure>());
      expect((result as ChatMessagesFailure).error, 'boom');
      expect(result.chatId, 'chat-2');
      expect(result.chatMessages, [message]);
      expect(result.pageNumber, 2);
      expect(result.totalChatMessagesInDatabase, 4);
    },
  );

  test(
    'given ChatMessagesFailure when copyWith omits optional values then it '
    'preserves existing values',
    () {
      // Arrange
      final state = ChatMessagesFailure(
        chatId: 'chat-1',
        error: 'boom',
        chatMessages: [message],
        pageNumber: 1,
        totalChatMessagesInDatabase: 4,
      );

      // Act
      final result = state.copyWith();

      // Assert
      expect(result, isA<ChatMessagesFailure>());
      expect((result as ChatMessagesFailure).error, 'boom');
      expect(result.chatId, 'chat-1');
      expect(result.chatMessages, [message]);
      expect(result.pageNumber, 1);
      expect(result.totalChatMessagesInDatabase, 4);
    },
  );
}
