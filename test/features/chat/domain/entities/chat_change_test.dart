import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

void main() {
  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );
  const user = User(id: 'user-1', name: 'Alice', email: 'alice@test.com');
  final chat = Chat(id: 'chat-1', lastMessage: message, members: const [user]);

  test('given a chat when ChatInserted is created then exposes the chat', () {
    // Act
    final change = ChatInserted(chat);

    // Assert
    expect(change.chat, chat);
  });

  test('given a chat when ChatUpdated is created then exposes the chat', () {
    // Act
    final change = ChatUpdated(chat);

    // Assert
    expect(change.chat, chat);
  });

  test('given a chat id when ChatDeleted is created then exposes the id', () {
    // Act
    final change = ChatDeleted('chat-1');

    // Assert
    expect(change.chatId, 'chat-1');
  });
}
