import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// A get chats count.
class GetChatsCount implements UseCase<int, NoParams> {
  /// Creates a [GetChatsCount].
  GetChatsCount({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;
  final ChatRepository _chatRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _chatRepository.getChatsCount();
  }
}
