part of 'chat_list_bloc.dart';

@immutable
/// Represents chats state.
sealed class ChatListState {
  const ChatListState({
    required this.chats,
    required this.nextCursor,
  });

  /// The chats.
  final List<Chat> chats;

  /// Opaque cursor used to request the next slice, when available.
  final String? nextCursor;

  /// Returns a new state of the same subtype with updated chat-list data.
  ChatListState copyWith({
    List<Chat>? chats,
    String? nextCursor,
  }) {
    return switch (this) {
      ChatListLoading() => ChatListLoading(
        chats: chats ?? this.chats,
        nextCursor: nextCursor ?? this.nextCursor,
      ),
      ChatListSuccess() => ChatListSuccess(
        chats: chats ?? this.chats,
        nextCursor: nextCursor ?? this.nextCursor,
      ),
      ChatListFailure(:final error) => ChatListFailure(
        error: error,
        chats: chats ?? this.chats,
        nextCursor: nextCursor ?? this.nextCursor,
      ),
    };
  }
}

/// A chats loading.
final class ChatListLoading extends ChatListState {
  /// Creates a [ChatListLoading].
  const ChatListLoading({
    required super.chats,
    required super.nextCursor,
  });
}

/// A chats success.
final class ChatListSuccess extends ChatListState {
  /// Creates a [ChatListSuccess].
  const ChatListSuccess({
    required super.chats,
    required super.nextCursor,
  });
}

/// Represents chats failure.
final class ChatListFailure extends ChatListState {
  /// Creates a [ChatListFailure].
  const ChatListFailure({
    required this.error,
    required super.chats,
    required super.nextCursor,
  });

  /// The error.
  final String error;
}
