import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// A get chat by members.
class GetChatByMembers implements UseCase<Chat?, GetChatByMembersParams> {
  /// Creates a [GetChatByMembers].
  GetChatByMembers({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;
  final ChatRepository _chatRepository;

  @override
  Future<Either<Failure, Chat?>> call(GetChatByMembersParams params) {
    return _chatRepository.getChatByMembers(params.members);
  }
}

/// A get chat by members params.
class GetChatByMembersParams {
  /// Creates a [GetChatByMembersParams].
  GetChatByMembersParams({required this.members});

  /// The members.
  final List<UserEntity> members;
}
