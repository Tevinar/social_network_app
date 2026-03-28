import 'package:social_app/core/constants/supabase_schema/fields/chat_fields.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';

/// A chat model.
class ChatModel {
  /// Creates a [ChatModel].
  ChatModel({
    required this.id,
    required this.lastMessage,
    required this.members,
  });

  /// Creates a [ChatModel].
  factory ChatModel.fromJson(Map<String, dynamic> map) {
    return ChatModel(
      id: map[ChatFields.id] as String,
      members: (map[Tables.chatMembers] as List<dynamic>)
          .map(
            (e) => UserModel.fromProfileJson(
              (e as Map<String, dynamic>)[Tables.profiles]
                  as Map<String, dynamic>,
            ),
          )
          .toList(),
      lastMessage: ChatMessageModel.fromJson(
        map[Tables.chatMessages] as Map<String, dynamic>,
      ),
    );
  }

  /// The id.
  final String id;

  /// The last message.
  final ChatMessageModel lastMessage;

  /// The members.
  final List<UserModel> members;

  /// The to json.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ChatFields.id: id,
      ChatFields.lastMessageId: lastMessage.id,
      ChatFields.lastMessageAt: lastMessage.createdAt.toIso8601String(),
    };
  }

  /// The to entity.
  Chat toEntity() {
    return Chat(
      id: id,
      lastMessage: lastMessage.toEntity(),
      members: members.map((e) => e.toEntity()).toList(),
    );
  }
}
