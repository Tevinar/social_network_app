import 'package:social_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatMessageModel {
  String id;
  String chatId;
  String authorId;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

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
