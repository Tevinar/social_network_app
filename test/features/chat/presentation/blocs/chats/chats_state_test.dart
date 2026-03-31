import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chats/chats_bloc.dart';

void main() {
  final chat = Chat(
    id: 'chat-1',
    lastMessage: ChatMessage(
      id: 'message-1',
      authorId: 'user-1',
      content: 'Hello',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    members: const [
      User(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
    ],
  );

  test(
    'given ChatsLoading when copyWith is called then returns ChatsLoading '
    'with updated values',
    () {
      // Arrange
      const state = ChatsLoading(chats: [], pageNumber: 1);

      // Act
      final result = state.copyWith(
        chats: [chat],
        pageNumber: 2,
        totalChatsInDatabase: 4,
      );

      // Assert
      expect(result, isA<ChatsLoading>());
      expect(result.chats, [chat]);
      expect(result.pageNumber, 2);
      expect(result.totalChatsInDatabase, 4);
    },
  );

  test(
    'given ChatsLoading when copyWith omits chats and totalChatsInDatabase '
    'then it preserves existing values',
    () {
      // Arrange
      final state = ChatsLoading(
        chats: [chat],
        pageNumber: 1,
        totalChatsInDatabase: 4,
      );

      // Act
      final result = state.copyWith(pageNumber: 2);

      // Assert
      expect(result, isA<ChatsLoading>());
      expect(result.chats, [chat]);
      expect(result.pageNumber, 2);
      expect(result.totalChatsInDatabase, 4);
    },
  );

  test(
    'given ChatsSuccess when copyWith is called then returns ChatsSuccess '
    'with updated values',
    () {
      // Arrange
      const state = ChatsSuccess(chats: [], pageNumber: 1);

      // Act
      final result = state.copyWith(
        chats: [chat],
        pageNumber: 2,
        totalChatsInDatabase: 4,
      );

      // Assert
      expect(result, isA<ChatsSuccess>());
      expect(result.chats, [chat]);
      expect(result.pageNumber, 2);
      expect(result.totalChatsInDatabase, 4);
    },
  );

  test(
    'given ChatsSuccess when copyWith omits chats then it preserves '
    'existing values',
    () {
      // Arrange
      final state = ChatsSuccess(
        chats: [chat],
        pageNumber: 1,
        totalChatsInDatabase: 4,
      );

      // Act
      final result = state.copyWith(pageNumber: 2);

      // Assert
      expect(result, isA<ChatsSuccess>());
      expect(result.chats, [chat]);
      expect(result.pageNumber, 2);
      expect(result.totalChatsInDatabase, 4);
    },
  );

  test(
    'given ChatsFailure when copyWith is called then preserves the error '
    'and updates other values',
    () {
      // Arrange
      const state = ChatsFailure(error: 'boom', chats: [], pageNumber: 1);

      // Act
      final result = state.copyWith(
        chats: [chat],
        pageNumber: 2,
        totalChatsInDatabase: 4,
      );

      // Assert
      expect(result, isA<ChatsFailure>());
      expect((result as ChatsFailure).error, 'boom');
      expect(result.chats, [chat]);
      expect(result.pageNumber, 2);
      expect(result.totalChatsInDatabase, 4);
    },
  );

  test(
    'given ChatsFailure when copyWith omits optional values then it '
    'preserves existing values',
    () {
      // Arrange
      final state = ChatsFailure(
        error: 'boom',
        chats: [chat],
        pageNumber: 1,
        totalChatsInDatabase: 4,
      );

      // Act
      final result = state.copyWith();

      // Assert
      expect(result, isA<ChatsFailure>());
      expect((result as ChatsFailure).error, 'boom');
      expect(result.chats, [chat]);
      expect(result.pageNumber, 1);
      expect(result.totalChatsInDatabase, 4);
    },
  );
}
