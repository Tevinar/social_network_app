import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';

void main() {
  final createdAt = DateTime(2025);
  final updatedAt = DateTime(2025, 1, 1, 1);

  test(
    'given a json when fromJson is called then returns a ChatMessageModel',
    () {
      // Arrange
      final json = <String, dynamic>{
        ChatMessageFields.id: 'message-1',
        ChatMessageFields.chatId: 'chat-1',
        ChatMessageFields.authorId: 'user-1',
        ChatMessageFields.content: 'Hello',
        ChatMessageFields.createdAt: createdAt.toIso8601String(),
        ChatMessageFields.updatedAt: updatedAt.toIso8601String(),
      };

      // Act
      final result = ChatMessageModel.fromJson(json);

      // Assert
      expect(result.id, 'message-1');
      expect(result.chatId, 'chat-1');
      expect(result.authorId, 'user-1');
      expect(result.content, 'Hello');
      expect(result.createdAt, createdAt);
      expect(result.updatedAt, updatedAt);
    },
  );

  test(
    'given a model when toEntity is called then returns a matching ChatMessage',
    () {
      // Arrange
      final model = ChatMessageModel(
        id: 'message-1',
        chatId: 'chat-1',
        authorId: 'user-1',
        content: 'Hello',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.id, 'message-1');
      expect(result.authorId, 'user-1');
      expect(result.content, 'Hello');
      expect(result.createdAt, createdAt);
      expect(result.updatedAt, updatedAt);
    },
  );
}
