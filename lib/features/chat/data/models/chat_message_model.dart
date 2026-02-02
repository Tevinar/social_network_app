import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/features/chat/domain/entities/chat_message.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatMessageModel {
  String id;
  UserModel author;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessageModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'author': author.toJson(),
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String,
      author: UserModel.fromJson(map['author'] as Map<String, dynamic>),
      content: map['content'] as String,
      createdAt: map['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] == null
          ? DateTime.now()
          : DateTime.parse(map['updated_at']),
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      author: author.toEntity(),
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
