import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';

void main() {
  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  test(
    'given a chat id and message when ChatMessageInserted is created then '
    'exposes both values',
    () {
      // Act
      final change = ChatMessageInserted(
        chatId: 'chat-1',
        chatMessage: message,
      );

      // Assert
      expect(change.chatId, 'chat-1');
      expect(change.chatMessage, message);
    },
  );

  test(
    'given a chat id and message when ChatMessageUpdated is created then '
    'exposes both values',
    () {
      // Act
      final change = ChatMessageUpdated(chatId: 'chat-1', chatMessage: message);

      // Assert
      expect(change.chatId, 'chat-1');
      expect(change.chatMessage, message);
    },
  );

  test(
    'given a chat id and message id when ChatMessageDeleted is created then '
    'exposes both values',
    () {
      // Act
      final change = ChatMessageDeleted(
        chatId: 'chat-1',
        chatMessageId: 'message-1',
      );

      // Assert
      expect(change.chatId, 'chat-1');
      expect(change.chatMessageId, 'message-1');
    },
  );
}
