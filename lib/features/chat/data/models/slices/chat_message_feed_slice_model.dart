import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_message_model.dart';

/// Data-layer representation of one cursor-based chat-message slice.
class ChatMessageFeedSliceModel {
  /// Creates a [ChatMessageFeedSliceModel].
  const ChatMessageFeedSliceModel({
    required this.chatMessages,
    required this.nextCursor,
  });

  /// Builds a [ChatMessageFeedSliceModel] from a backend JSON payload.
  factory ChatMessageFeedSliceModel.fromJson(Map<String, dynamic> json) {
    final chatMessages = JsonReader.readList(json, 'chatMessages');

    return ChatMessageFeedSliceModel(
      chatMessages: chatMessages
          .map(
            (item) => ChatMessageModel.fromJson(
              JsonReader.asObject(item, 'chatMessages[]'),
            ),
          )
          .toList(),
      nextCursor: JsonReader.readNullableString(json, 'nextCursor'),
    );
  }

  /// Chat messages returned in the current slice.
  final List<ChatMessageModel> chatMessages;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
