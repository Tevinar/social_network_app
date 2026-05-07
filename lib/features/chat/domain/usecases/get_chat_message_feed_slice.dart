import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_feed_slice.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Loads one cursor-based slice of messages for a chat.
class GetChatMessageFeedSlice
    implements UseCase<ChatMessageFeedSlice, GetChatMessageFeedSliceParams> {
  /// Creates a [GetChatMessageFeedSlice].
  GetChatMessageFeedSlice({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to load chat messages.
  final ChatRepository _chatRepository;

  @override
  /// Validates the slice size, then loads the messages.
  Future<Either<Failure, ChatMessageFeedSlice>> call(
    GetChatMessageFeedSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure('Limit must be greater than zero')),
      );
    }

    return _chatRepository.getChatMessageFeedSlice(
      chatId: params.chatId,
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one chat-message slice.
class GetChatMessageFeedSliceParams {
  /// Creates a [GetChatMessageFeedSliceParams].
  const GetChatMessageFeedSliceParams({
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
