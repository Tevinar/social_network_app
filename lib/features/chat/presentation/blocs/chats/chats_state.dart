part of 'chats_bloc.dart';

@immutable
sealed class ChatsState {
  const ChatsState({
    required this.chats,
    required this.pageNumber,
    this.totalChatsInDatabase,
  });
  final List<Chat> chats;
  final int pageNumber;
  final int? totalChatsInDatabase;

  ChatsState copyWith({
    List<Chat>? chats,
    int? pageNumber,
    int? totalChatsInDatabase,
  }) {
    return switch (this) {
      ChatsLoading() => ChatsLoading(
        chats: chats ?? this.chats,
        pageNumber: pageNumber ?? this.pageNumber,
        totalChatsInDatabase: totalChatsInDatabase ?? this.totalChatsInDatabase,
      ),

      ChatsSuccess() => ChatsSuccess(
        chats: chats ?? this.chats,
        pageNumber: pageNumber ?? this.pageNumber,
        totalChatsInDatabase: totalChatsInDatabase ?? this.totalChatsInDatabase,
      ),

      ChatsFailure(:final error) => ChatsFailure(
        error: error,
        chats: chats ?? this.chats,
        pageNumber: pageNumber ?? this.pageNumber,
        totalChatsInDatabase: totalChatsInDatabase ?? this.totalChatsInDatabase,
      ),
    };
  }
}

final class ChatsLoading extends ChatsState {
  const ChatsLoading({
    required super.chats,
    required super.pageNumber,
    super.totalChatsInDatabase,
  });
}

final class ChatsSuccess extends ChatsState {
  const ChatsSuccess({
    required super.chats,
    required super.pageNumber,
    super.totalChatsInDatabase,
  });
}

final class ChatsFailure extends ChatsState {
  const ChatsFailure({
    required this.error,
    required super.chats,
    required super.pageNumber,
    super.totalChatsInDatabase,
  });
  final String error;
}
