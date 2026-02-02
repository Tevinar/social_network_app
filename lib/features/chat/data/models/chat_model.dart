import 'package:bloc_app/core/constants/supabase_schema/tables.dart';
import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/features/chat/data/models/chat_message_model.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';

class ChatModel {
  final String id;
  final ChatMessageModel lastMessage;
  final List<UserModel> members;

  ChatModel({
    required this.id,
    required this.lastMessage,
    required this.members,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'members': members.map((e) => e.toJson()).toList(),
      'lastMessage': lastMessage.toJson(),
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'],
      members: (map[Tables.profiles] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: ChatMessageModel.fromJson(map[Tables.chatMessages][0]),
    );
  }

  Chat toEntity() {
    return Chat(
      id: id,
      lastMessage: lastMessage.toEntity(),
      members: members.map((e) => e.toEntity()).toList(),
    );
  }
}
