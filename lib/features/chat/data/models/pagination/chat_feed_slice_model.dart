import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';
import 'package:social_app/features/chat/domain/pagination/chat_feed_slice.dart';

/// Data-layer representation of one cursor-based chat-feed slice.
class ChatFeedSliceModel {
  /// Creates a [ChatFeedSliceModel].
  const ChatFeedSliceModel({
    required this.chats,
    required this.nextCursor,
  });

  /// Builds a [ChatFeedSliceModel] from a backend JSON payload.
  factory ChatFeedSliceModel.fromJson(Map<String, dynamic> json) {
    final chats = JsonReader.readList(json, 'chats');

    return ChatFeedSliceModel(
      chats: chats
          .map(
            (chat) => ChatModel.fromJson(JsonReader.asObject(chat, 'chats[]')),
          )
          .toList(),
      nextCursor: JsonReader.readNullableString(json, 'nextCursor'),
    );
  }

  /// Chats returned in the current slice.
  final List<ChatModel> chats;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;

  /// Converts the model to the domain [ChatFeedSlice] value.
  ChatFeedSlice toSlice() {
    return ChatFeedSlice(
      chats: chats.map((chat) => chat.toEntity()).toList(),
      nextCursor: nextCursor,
    );
  }
}
