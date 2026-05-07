import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_last_message_model.dart';
import 'package:social_app/features/chat/data/models/common/chat_user_summary_model.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';

/// Data-layer representation of one chat payload returned by the backend.
class ChatModel {
  /// Creates a [ChatModel].
  const ChatModel({
    required this.id,
    required this.members,
    required this.lastMessage,
  });

  /// Builds a [ChatModel] from a backend JSON payload.
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final members = JsonReader.readList(json, 'members');
    final lastMessageJson = json['lastMessage'];

    return ChatModel(
      id: JsonReader.readString(json, 'id'),
      members: members
          .map(
            (item) => ChatUserSummaryModel.fromJson(
              JsonReader.asObject(item, 'members[]'),
            ),
          )
          .toList(),
      lastMessage: lastMessageJson is Map<String, dynamic>
          ? ChatLastMessageModel.fromJson(lastMessageJson)
          : null,
    );
  }

  /// Stable chat identifier.
  final String id;

  /// Public members of the chat.
  final List<ChatUserSummaryModel> members;

  /// Latest message preview shown for the chat.
  final ChatLastMessageModel? lastMessage;

  /// Converts the data model into the domain [Chat] entity.
  Chat toEntity() {
    final lastMessage = this.lastMessage;

    if (lastMessage == null) {
      throw StateError('ChatModel.lastMessage must not be null');
    }

    return Chat(
      id: id,
      lastMessage: lastMessage.toEntity(),
      members: members.map((member) => member.toEntity()).toList(),
    );
  }
}
