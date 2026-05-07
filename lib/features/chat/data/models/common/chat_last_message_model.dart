import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_user_summary_model.dart';
import 'package:social_app/features/chat/domain/entities/chat_last_message.dart';

/// Data-layer representation of the latest message preview shown for one chat.
class ChatLastMessageModel {
  /// Creates a [ChatLastMessageModel].
  const ChatLastMessageModel({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  /// Builds a [ChatLastMessageModel] from a backend JSON payload.
  factory ChatLastMessageModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'];

    return ChatLastMessageModel(
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
  ChatLastMessage toEntity() {
    return ChatLastMessage(
      id: id,
      author: author?.toEntity(),
      content: content,
      createdAt: createdAt,
    );
  }
}
