import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_user_summary_model.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';

/// Data-layer representation of one chat payload returned by the backend.
class ChatModel {
  /// Creates a [ChatModel].
  const ChatModel._chatModel({
    required this.id,
    required this.members,
    required _ChatLastMessageModel? lastMessage,
  }) : _lastMessage = lastMessage;

  /// Builds a [ChatModel] from a backend JSON payload.
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final members = JsonReader.readList(json, 'members');
    final lastMessageJson = json['lastMessage'];

    return ChatModel._chatModel(
      id: JsonReader.readString(json, 'id'),
      members: members
          .map(
            (item) => ChatUserSummaryModel.fromJson(
              JsonReader.asObject(item, 'members[]'),
            ),
          )
          .toList(),
      lastMessage: lastMessageJson is Map<String, dynamic>
          ? _ChatLastMessageModel.fromJson(lastMessageJson)
          : null,
    );
  }

  /// Stable chat identifier.
  final String id;

  /// Public members of the chat.
  final List<ChatUserSummaryModel> members;

  /// Latest message preview shown for the chat.
  final _ChatLastMessageModel? _lastMessage;

  /// Converts the data model into the domain [Chat] entity.
  Chat toEntity() {
    return Chat(
      id: id,
      lastMessage: _lastMessage?._toEntity(),
      members: members.map((member) => member.toEntity()).toList(),
    );
  }
}

/// Data-layer representation of the latest message preview shown for one chat.
class _ChatLastMessageModel {
  /// Creates a [_ChatLastMessageModel].
  const _ChatLastMessageModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  /// Builds a [_ChatLastMessageModel] from a backend JSON payload.
  factory _ChatLastMessageModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'];

    return _ChatLastMessageModel(
      id: JsonReader.readString(json, 'id'),
      author: authorJson is Map<String, dynamic>
          ? ChatUserSummaryModel.fromJson(authorJson)
          : null,
      content: JsonReader.readString(json, 'content'),
      createdAt: JsonReader.readDateTime(json, 'createdAt'),
    );
  }

  /// Stable message identifier.
  final String id;

  /// Message author when still available.
  final ChatUserSummaryModel? author;

  /// Preview content shown in chat lists.
  final String content;

  /// Message creation timestamp.
  final DateTime createdAt;

  /// Converts the model to the domain [ChatLastMessage] entity.
  ChatLastMessage _toEntity() {
    return ChatLastMessage(
      id: id,
      author: author?.toEntity(),
      content: content,
      createdAt: createdAt,
    );
  }
}
