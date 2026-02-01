import 'package:bloc_app/features/chat/domain/entities/chat.dart';

class ChatModel {
  final String id;
  ChatModel({required this.id});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id};
  }

  factory ChatModel.fromJson(Map<String, dynamic> map) {
    return ChatModel(id: map['id']);
  }

  Chat toEntity() {
    return Chat(id: id);
  }
}
