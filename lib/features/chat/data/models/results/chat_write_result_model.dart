import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_message_model.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';

/// Data-layer representation of one successful chat write response.
class ChatWriteResultModel {
  /// Creates a [ChatWriteResultModel].
  const ChatWriteResultModel({
    required this.chat,
    required this.chatMessage,
  });

  /// Builds a [ChatWriteResultModel] from the create-chat response payload.
  factory ChatWriteResultModel.fromCreateChatJson(
    Map<String, dynamic> json,
  ) {
    return ChatWriteResultModel(
      chat: ChatModel.fromJson(JsonReader.readObject(json, 'chat')),
      chatMessage: ChatMessageModel.fromJson(
        JsonReader.readObject(json, 'chatMessage'),
      ),
    );
  }

  /// Builds a [ChatWriteResultModel] from the create-chat-message response
  /// payload.
  factory ChatWriteResultModel.fromCreateChatMessageJson(
    Map<String, dynamic> json,
  ) {
    return ChatWriteResultModel(
      chat: ChatModel.fromJson(JsonReader.readObject(json, 'chat')),
      chatMessage: ChatMessageModel.fromJson(
        JsonReader.readObject(json, 'chatMessage'),
      ),
    );
  }

  /// Updated chat payload returned by the backend.
  final ChatModel chat;

  /// Newly created message payload returned by the backend.
  final ChatMessageModel chatMessage;
}
