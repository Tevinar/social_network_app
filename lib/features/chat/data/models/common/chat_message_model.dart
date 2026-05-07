import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_last_message_model.dart';
import 'package:social_app/features/chat/data/models/common/chat_user_summary_model.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';

/// Data-layer representation of one chat message returned by the backend.
class ChatMessageModel {
  /// Creates a [ChatMessageModel].
  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.author,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Builds a [ChatMessageModel] from a backend JSON payload.
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'];

    return ChatMessageModel(
      id: JsonReader.readString(json, 'id'),
      chatId: JsonReader.readString(json, 'chatId'),
      author: authorJson is Map<String, dynamic>
          ? ChatUserSummaryModel.fromJson(authorJson)
          : null,
      content: JsonReader.readString(json, 'content'),
      createdAt: JsonReader.readDateTime(json, 'createdAt'),
      updatedAt: JsonReader.readDateTime(json, 'updatedAt'),
    );
  }

  /// Builds a [ChatMessageModel] from a chat last-message payload.
  factory ChatMessageModel.fromLastMessage(ChatLastMessageModel lastMessage) {
    return ChatMessageModel(
      id: lastMessage.id,
      chatId: '',
      author: lastMessage.author,
      content: lastMessage.content,
      createdAt: lastMessage.createdAt,
      updatedAt: lastMessage.createdAt,
    );
  }

  /// Unique message identifier.
  final String id;

  /// Identifier of the chat that owns this message.
  final String chatId;

  /// Message author when still available.
  final ChatUserSummaryModel? author;

  /// Message text content.
  final String content;

  /// Creation timestamp from the backend.
  final DateTime createdAt;

  /// Last update timestamp from the backend.
  final DateTime updatedAt;

  /// Converts the model to the domain [ChatMessage] entity.
  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      authorId: author?.id ?? '',
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
