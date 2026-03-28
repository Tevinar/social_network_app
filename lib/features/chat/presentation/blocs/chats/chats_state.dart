part of 'chats_bloc.dart';

@immutable
/// Represents chats state.
sealed class ChatsState {
  const ChatsState({
    required this.chats,
    required this.pageNumber,
    this.totalChatsInDatabase,
  });

  /// The chats.
  final List<Chat> chats;

  /// The int.
  final int pageNumber;

  /// The int.
  final int? totalChatsInDatabase;

  /// The copy with.
  ChatsState copyWith({
    /// The chats.
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

/// A chats loading.
final class ChatsLoading extends ChatsState {
  /// Creates a [ChatsLoading].
  const ChatsLoading({
    required super.chats,
    required super.pageNumber,
    super.totalChatsInDatabase,
  });
}

/// A chats success.
final class ChatsSuccess extends ChatsState {
  /// Creates a [ChatsSuccess].
  const ChatsSuccess({
    required super.chats,
    required super.pageNumber,
    super.totalChatsInDatabase,
  });
}

/// Represents chats failure.
final class ChatsFailure extends ChatsState {
  /// Creates a [ChatsFailure].
  const ChatsFailure({
    required this.error,
    required super.chats,
    required super.pageNumber,
    super.totalChatsInDatabase,
  });

  /// The error.
  final String error;
}
