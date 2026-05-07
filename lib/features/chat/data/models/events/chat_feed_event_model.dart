import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';

/// Data-layer representation of one chat-feed event received over SSE.
class ChatFeedEventModel {
  /// Creates a [ChatFeedEventModel].
  const ChatFeedEventModel({
    required this.type,
    required this.item,
  });

  /// Builds a [ChatFeedEventModel] from one parsed SSE event.
  factory ChatFeedEventModel.fromSseEvent(SseEvent event) {
    return ChatFeedEventModel(
      type: event.type ?? JsonReader.readString(event.data, 'type'),
      item: ChatModel.fromJson(JsonReader.readObject(event.data, 'item')),
    );
  }

  /// Event name emitted by the backend feed stream.
  final String type;

  /// Chat payload carried by the event.
  final ChatModel item;

  /// Converts the model to the domain-level [ChatChange] entity.
  ChatChange toEntity() {
    switch (type) {
      case 'feed.chat_added':
        return ChatInserted(item.toEntity());
      case 'feed.chat_updated':
        return ChatUpdated(item.toEntity());
      default:
        throw FormatException('Unsupported chat feed event type: $type');
    }
  }
}
