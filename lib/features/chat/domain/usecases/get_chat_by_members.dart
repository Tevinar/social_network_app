import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/usecases/usecase.dart';
import 'package:social_network_app/features/auth/domain/entities/user.dart';
import 'package:social_network_app/features/chat/domain/entities/chat.dart';
import 'package:social_network_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetChatByMembers implements UseCase<Chat?, GetChatByMembersParams> {
  final ChatRepository _chatRepository;

  GetChatByMembers({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, Chat?>> call(GetChatByMembersParams params) {
    return _chatRepository.getChatByMembers(params.members);
  }
}

class GetChatByMembersParams {
  final List<User> members;

  GetChatByMembersParams({required this.members});
}
