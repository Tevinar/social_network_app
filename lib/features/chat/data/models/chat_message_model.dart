import 'package:bloc_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:bloc_app/features/chat/domain/entities/chat_message.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatMessageModel {
  String id;
  String authorId;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessageModel({
    required this.id,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ChatMessageFields.id: id,
      ChatMessageFields.authorId: authorId,
      ChatMessageFields.content: content,
      ChatMessageFields.createdAt: createdAt.toIso8601String(),
      ChatMessageFields.updatedAt: updatedAt.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map[ChatMessageFields.id],
      authorId: map[ChatMessageFields.authorId],
      content: map[ChatMessageFields.content],
      createdAt: DateTime.parse(map[ChatMessageFields.createdAt]),
      updatedAt: DateTime.parse(map[ChatMessageFields.updatedAt]),
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
