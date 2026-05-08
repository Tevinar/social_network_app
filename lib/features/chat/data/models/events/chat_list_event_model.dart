import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';

/// Data-layer representation of one chat-list event received over SSE.
class ChatListEventModel {
  /// Creates a [ChatListEventModel].
  const ChatListEventModel({
    required this.type,
    required this.chat,
  });

  /// Builds a [ChatListEventModel] from one parsed SSE event.
  factory ChatListEventModel.fromSseEvent(SseEvent event) {
    return ChatListEventModel(
      type: event.type ?? JsonReader.readString(event.data, 'type'),
      chat: ChatModel.fromJson(JsonReader.readObject(event.data, 'chat')),
    );
  }

  /// Event name emitted by the backend chat-list stream.
  final String type;

  /// Chat payload carried by the event.
  final ChatModel chat;

  /// Converts the model to the domain-level [ChatListChange] entity.
  ChatListChange toEvent() {
    switch (type) {
      case 'chat.added':
        return ChatInserted(chat.toEntity());
      case 'chat.updated':
        return ChatUpdated(chat.toEntity());
      default:
        throw FormatException('Unsupported chat list event type: $type');
    }
  }
}
