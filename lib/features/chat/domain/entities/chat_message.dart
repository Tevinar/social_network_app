// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_app/features/auth/domain/entities/user.dart';

class ChatMessage {
  String id;
  User author;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  ChatMessage({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}
