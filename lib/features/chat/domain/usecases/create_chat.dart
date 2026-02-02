// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/repositories/chat_repository.dart';

class CreateChat implements UseCase<Chat, List<User>> {
  final ChatRepository _chatRepository;
  CreateChat({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, Chat>> call(List<User> params) {
    List<String> memberIds = params.map((user) => user.id).toList();
    return _chatRepository.createChat(memberIds);
  }
}
