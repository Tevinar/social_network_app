import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

void main() {
  test(
    'given constructor values when Chat is created then exposes them',
    () {
      // Arrange
      final message = ChatMessage(
        id: 'message-1',
        authorId: 'user-1',
        content: 'Hello',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      const user = UserEntity(
        id: 'user-1',
        name: 'Alice',
        email: 'alice@test.com',
      );

      // Act
      final chat = Chat(
        id: 'chat-1',
        lastMessage: message,
        members: const [user],
      );

      // Assert
      expect(chat.id, 'chat-1');
      expect(chat.lastMessage, message);
      expect(chat.members, const [user]);
    },
  );
}
