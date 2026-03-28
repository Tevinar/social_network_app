// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

class CreateChat implements UseCase<Chat, CreateChatParams> {
  final ChatRepository _chatRepository;
  CreateChat({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, Chat>> call(CreateChatParams params) {
    if (params.firstMessageContent.trim().isEmpty) {
      return Future.value(
        left(const ValidationFailure('Message cannot be empty')),
      );
    }
    return _chatRepository.createChat(
      params.members,
      params.firstMessageContent,
    );
  }
}

class CreateChatParams {
  final List<User> members;
  final String firstMessageContent;
  CreateChatParams({required this.members, required this.firstMessageContent});
}
