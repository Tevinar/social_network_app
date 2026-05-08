import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_list_slice.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Loads one cursor-based slice of messages for a chat.
class GetChatMessageListSlice
    implements UseCase<ChatMessageListSlice, GetChatMessageListSliceParams> {
  /// Creates a [GetChatMessageListSlice].
  GetChatMessageListSlice({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to load chat messages.
  final ChatRepository _chatRepository;

  @override
  /// Validates the slice size, then loads the messages.
  Future<Either<Failure, ChatMessageListSlice>> call(
    GetChatMessageListSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure('Limit must be greater than zero')),
      );
    }

    return _chatRepository.getChatMessageListSlice(
      chatId: params.chatId,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one chat-message slice.
class GetChatMessageListSliceParams {
  /// Creates a [GetChatMessageListSliceParams].
  const GetChatMessageListSliceParams({
    required this.chatId,
    required this.limit,
    this.cursor,
  });

  /// Identifier of the chat whose messages should be loaded.
  final String chatId;

  /// Maximum number of messages to return.
  final int limit;

  /// Opaque cursor of the next slice to load.
  final String? cursor;
}
