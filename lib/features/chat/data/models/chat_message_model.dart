import 'package:social_app/core/constants/supabase_schema/fields/'
    'chat_message_fields.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// Data model used to serialize chat message payloads from the backend.
class ChatMessageModel {
  /// Creates a [ChatMessageModel].
  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [ChatMessageModel] from a serialized backend payload.
  factory ChatMessageModel.fromJson(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map[ChatMessageFields.id] as String,
      chatId: map[ChatMessageFields.chatId] as String,
      authorId: map[ChatMessageFields.authorId] as String,
      content: map[ChatMessageFields.content] as String,
      createdAt: DateTime.parse(map[ChatMessageFields.createdAt] as String),
      updatedAt: DateTime.parse(map[ChatMessageFields.updatedAt] as String),
    );
  }

  /// Unique message identifier.
  String id;

  /// Identifier of the chat that owns this message.
  String chatId;

  /// Identifier of the message author.
  String authorId;

  /// Message text content.
  String content;

  /// Creation timestamp from the backend.
  DateTime createdAt;

  /// Last update timestamp from the backend.
  DateTime updatedAt;

  /// Converts the model to the domain [ChatMessage] entity.
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
