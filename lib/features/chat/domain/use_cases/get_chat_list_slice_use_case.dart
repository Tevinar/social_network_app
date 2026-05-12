import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failure_messages.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/pagination/chat_list_slice.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Loads one cursor-based slice of the chat list.
class GetChatListSliceUseCase
    implements UseCase<ChatListSlice, GetChatListSliceParams> {
  /// Creates a [GetChatListSliceUseCase].
  GetChatListSliceUseCase({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to load chat-list data.
  final ChatRepository _chatRepository;

  @override
  /// Validates the requested slice size, then loads the list slice.
  Future<Either<Failure, ChatListSlice>> call(
    GetChatListSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure(CommonFailureMessages.invalidLimit)),
      );
    }

    return _chatRepository.getChatListSlice(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one chat-list slice.
class GetChatListSliceParams {
  /// Creates a [GetChatListSliceParams].
  const GetChatListSliceParams({
    required this.limit,
    this.cursor,
  });

  /// Maximum number of chats to return.
  final int limit;

  /// Opaque cursor of the next slice to load.
  final String? cursor;
}
