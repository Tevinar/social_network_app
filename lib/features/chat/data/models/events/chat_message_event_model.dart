import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_message_model.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';

/// Data-layer representation of one chat-message event received over SSE.
class ChatMessageEventModel {
  /// Creates a [ChatMessageEventModel].
  const ChatMessageEventModel({
    required this.type,
    required this.item,
  });

  /// Builds a [ChatMessageEventModel] from one parsed SSE event.
  factory ChatMessageEventModel.fromSseEvent(SseEvent event) {
    return ChatMessageEventModel(
      type: event.type ?? JsonReader.readString(event.data, 'type'),
      item: ChatMessageModel.fromJson(
        JsonReader.readObject(event.data, 'item'),
      ),
    );
  }

  /// Event name emitted by the backend message stream.
  final String type;

  /// Chat-message payload carried by the event.
  final ChatMessageModel item;

  /// Converts the model to the domain-level [ChatMessageChange] entity.
  ChatMessageChange toEntity() {
    switch (type) {
      case 'message.added':
        return ChatMessageInserted(
          chatId: item.chatId,
          chatMessage: item.toEntity(),
        );
      default:
        throw FormatException('Unsupported chat message event type: $type');
    }
  }
}
