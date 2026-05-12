import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_message_model.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_list_slice.dart';

/// Data-layer representation of one cursor-based chat-message slice.
class ChatMessageListSliceModel {
  /// Creates a [ChatMessageListSliceModel].
  const ChatMessageListSliceModel({
    required this.chatMessages,
    required this.nextCursor,
  });

  /// Builds a [ChatMessageListSliceModel] from a backend JSON payload.
  factory ChatMessageListSliceModel.fromJson(Map<String, dynamic> json) {
    final chatMessages = JsonReader.readList(json, 'chatMessages');

    return ChatMessageListSliceModel(
      chatMessages: chatMessages
          .map(
            (chatMessage) => ChatMessageModel.fromJson(
              JsonReader.asObject(chatMessage, 'chatMessages[]'),
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

  /// Converts the model to the domain [ChatMessageListSlice] value.
  ChatMessageListSlice toSlice() {
    return ChatMessageListSlice(
      chatMessages: chatMessages
          .map((chatMessage) => chatMessage.toEntity())
          .toList(),
      nextCursor: nextCursor,
    );
  }
}
