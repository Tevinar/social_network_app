import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

void main() {
  test(
    'given constructor values when ChatMessage is created then exposes them',
    () {
      // Act
      final message = ChatMessage(
        id: 'message-1',
        authorId: 'user-1',
        content: 'Hello',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025, 1, 1, 1),
      );

      // Assert
      expect(message.id, 'message-1');
      expect(message.authorId, 'user-1');
      expect(message.content, 'Hello');
      expect(message.createdAt, DateTime(2025));
      expect(message.updatedAt, DateTime(2025, 1, 1, 1));
    },
  );
}
