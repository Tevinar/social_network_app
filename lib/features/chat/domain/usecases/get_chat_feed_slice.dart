import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/pagination/chat_feed_slice.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Loads one cursor-based slice of the chat feed.
class GetChatFeedSlice
    implements UseCase<ChatFeedSlice, GetChatFeedSliceParams> {
  /// Creates a [GetChatFeedSlice].
  GetChatFeedSlice({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to load chat-feed data.
  final ChatRepository _chatRepository;

  @override
  /// Validates the requested slice size, then loads the feed slice.
  Future<Either<Failure, ChatFeedSlice>> call(
    GetChatFeedSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure('Limit must be greater than zero')),
      );
    }

    return _chatRepository.getChatFeedSlice(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one chat-feed slice.
class GetChatFeedSliceParams {
  /// Creates a [GetChatFeedSliceParams].
  const GetChatFeedSliceParams({
    required this.limit,
    this.cursor,
  });

  /// Maximum number of chats to return.
  final int limit;

  /// Opaque cursor of the next slice to load.
  final String? cursor;
}
