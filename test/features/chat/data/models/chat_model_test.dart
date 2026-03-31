import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/constants/supabase_schema/fields/chat_fields.dart';
import 'package:social_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/features/chat/data/models/chat_model.dart';

void main() {
  final createdAt = DateTime(2025);
  final updatedAt = DateTime(2025, 1, 1, 1);

  test(
    'given a json when fromJson is called then returns a ChatModel',
    () {
      // Arrange
      final json = <String, dynamic>{
        ChatFields.id: 'chat-1',
        Tables.chatMembers: [
          {
            Tables.profiles: <String, dynamic>{
              'id': 'user-1',
              'name': 'Alice',
            },
          },
        ],
        Tables.chatMessages: <String, dynamic>{
          ChatMessageFields.id: 'message-1',
          ChatMessageFields.chatId: 'chat-1',
          ChatMessageFields.authorId: 'user-1',
          ChatMessageFields.content: 'Hello',
          ChatMessageFields.createdAt: createdAt.toIso8601String(),
          ChatMessageFields.updatedAt: updatedAt.toIso8601String(),
        },
      };

      // Act
      final result = ChatModel.fromJson(json);

      // Assert
      expect(result.id, 'chat-1');
      expect(result.members.first.id, 'user-1');
      expect(result.members.first.name, 'Alice');
      expect(result.lastMessage.id, 'message-1');
    },
  );

  test(
    'given a model when toJson is called then returns a serializable map',
    () {
      // Arrange
      final model = ChatModel.fromJson(
        <String, dynamic>{
          ChatFields.id: 'chat-1',
          Tables.chatMembers: [
            {
              Tables.profiles: <String, dynamic>{
                'id': 'user-1',
                'name': 'Alice',
              },
            },
          ],
          Tables.chatMessages: <String, dynamic>{
            ChatMessageFields.id: 'message-1',
            ChatMessageFields.chatId: 'chat-1',
            ChatMessageFields.authorId: 'user-1',
            ChatMessageFields.content: 'Hello',
            ChatMessageFields.createdAt: createdAt.toIso8601String(),
            ChatMessageFields.updatedAt: updatedAt.toIso8601String(),
          },
        },
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result, <String, dynamic>{
        ChatFields.id: 'chat-1',
        ChatFields.lastMessageId: 'message-1',
        ChatFields.lastMessageAt: createdAt.toIso8601String(),
      });
    },
  );

  test(
    'given a model when toEntity is called then returns a matching Chat',
    () {
      // Arrange
      final model = ChatModel.fromJson(
        <String, dynamic>{
          ChatFields.id: 'chat-1',
          Tables.chatMembers: [
            {
              Tables.profiles: <String, dynamic>{
                'id': 'user-1',
                'name': 'Alice',
              },
            },
          ],
          Tables.chatMessages: <String, dynamic>{
            ChatMessageFields.id: 'message-1',
            ChatMessageFields.chatId: 'chat-1',
            ChatMessageFields.authorId: 'user-1',
            ChatMessageFields.content: 'Hello',
            ChatMessageFields.createdAt: createdAt.toIso8601String(),
            ChatMessageFields.updatedAt: updatedAt.toIso8601String(),
          },
        },
      );

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.id, 'chat-1');
      expect(result.members.first.id, 'user-1');
      expect(result.lastMessage.id, 'message-1');
    },
  );
}
