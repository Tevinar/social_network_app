import 'package:social_app/core/constants/supabase_schema/fields/chat_fields.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';

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
      ChatFields.id: id,
      ChatFields.lastMessageId: lastMessage.id,
      ChatFields.lastMessageAt: lastMessage.createdAt.toIso8601String(),
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> map) {
    return ChatModel(
      id: map[ChatFields.id],
      members: (map[Tables.chatMembers] as List<dynamic>)
          .map((e) => UserModel.fromProfileJson(e[Tables.profiles]))
          .toList(),
      lastMessage: ChatMessageModel.fromJson(map[Tables.chatMessages]),
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
