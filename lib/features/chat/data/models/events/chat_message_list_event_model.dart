import 'package:social_app/core/network/sse/sse_event.dart';
import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_message_model.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';

/// Data-layer representation of one chat-message list event received over SSE.
class ChatMessageListEventModel {
  /// Creates a [ChatMessageListEventModel].
  const ChatMessageListEventModel({
    required this.type,
    required this.chatMessage,
  });

  /// Builds a [ChatMessageListEventModel] from one parsed SSE event.
  factory ChatMessageListEventModel.fromSseEvent(SseEvent event) {
    return ChatMessageListEventModel(
      type: event.type ?? JsonReader.readString(event.data, 'type'),
      chatMessage: ChatMessageModel.fromJson(
        JsonReader.readObject(event.data, 'chatMessage'),
      ),
    );
  }

  /// Event name emitted by the backend message stream.
  final String type;

  /// Chat-message payload carried by the event.
  final ChatMessageModel chatMessage;

  /// Converts the model to the domain-level [ChatMessageListChange] entity.
  ChatMessageListChange toEvent() {
    switch (type) {
      case 'chat_message.added':
        return ChatMessageInserted(
          chatId: chatMessage.chatId,
          chatMessage: chatMessage.toEntity(),
        );
      default:
        throw FormatException('Unsupported chat message event type: $type');
    }
  }
}
