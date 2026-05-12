import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/pagination/chat_candidate_list_slice.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Loads one cursor-based slice of chat candidates.
class GetChatCandidateListSliceUseCase
    implements
        UseCase<ChatCandidateListSlice, GetChatCandidateListSliceParams> {
  /// Creates a [GetChatCandidateListSliceUseCase].
  GetChatCandidateListSliceUseCase({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to load chat candidates.
  final ChatRepository _chatRepository;

  @override
  /// Validates the requested slice size, then loads the candidate slice.
  Future<Either<Failure, ChatCandidateListSlice>> call(
    GetChatCandidateListSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure('Limit must be greater than zero')),
      );
    }

    return _chatRepository.getChatCandidateListSlice(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one chat-candidate slice.
class GetChatCandidateListSliceParams {
  /// Creates a [GetChatCandidateListSliceParams].
  const GetChatCandidateListSliceParams({
    required this.limit,
    this.cursor,
  });

  /// Maximum number of candidates to return.
  final int limit;

  /// Opaque cursor of the next slice to load.
  final String? cursor;
}
