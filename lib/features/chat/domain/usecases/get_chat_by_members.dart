import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Looks up one existing chat by its exact member set.
class GetChatByMembers implements UseCase<Chat?, GetChatByMembersParams> {
  /// Creates a [GetChatByMembers].
  GetChatByMembers({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to search chats by members.
  final ChatRepository _chatRepository;

  @override
  /// Validates the selected member set, then looks up the chat if possible.
  Future<Either<Failure, Chat?>> call(GetChatByMembersParams params) {
    if (params.memberIds.isEmpty) {
      return Future.value(
        left(
          const ValidationFailure('At least one chat member must be selected'),
        ),
      );
    }

    return _chatRepository.getChatByMembers(
      memberIds: params.memberIds,
    );
  }
}

/// Parameters required to find one chat by members.
class GetChatByMembersParams {
  /// Creates a [GetChatByMembersParams].
  const GetChatByMembersParams({
    required this.memberIds,
  });

  /// Target member identifiers, excluding the current user.
  final List<String> memberIds;
}
