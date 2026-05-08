import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';
import 'package:social_app/features/chat/domain/pagination/chat_list_slice.dart';

/// Data-layer representation of one cursor-based chat-list slice.
class ChatListSliceModel {
  /// Creates a [ChatListSliceModel].
  const ChatListSliceModel({
    required this.chats,
    required this.nextCursor,
  });

  /// Builds a [ChatListSliceModel] from a backend JSON payload.
  factory ChatListSliceModel.fromJson(Map<String, dynamic> json) {
    final chats = JsonReader.readList(json, 'chats');

    return ChatListSliceModel(
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

  /// Converts the model to the domain [ChatListSlice] value.
  ChatListSlice toSlice() {
    return ChatListSlice(
      chats: chats.map((chat) => chat.toEntity()).toList(),
      nextCursor: nextCursor,
    );
  }
}
