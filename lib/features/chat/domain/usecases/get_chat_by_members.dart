import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

class GetChatByMembers implements UseCase<Chat?, GetChatByMembersParams> {
  GetChatByMembers({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;
  final ChatRepository _chatRepository;

  @override
  Future<Either<Failure, Chat?>> call(GetChatByMembersParams params) {
    return _chatRepository.getChatByMembers(params.members);
  }
}

class GetChatByMembersParams {
  GetChatByMembersParams({required this.members});
  final List<User> members;
}
