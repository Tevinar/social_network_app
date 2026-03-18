import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetChatsPage implements UseCase<List<Chat>, int> {
  final ChatRepository _chatRepository;
  GetChatsPage({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  @override
  Future<Either<Failure, List<Chat>>> call(int params) {
    return _chatRepository.getChatsPage(params);
  }
}
