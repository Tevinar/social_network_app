import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// A get chats page widget.
class GetChatsPage implements UseCase<List<Chat>, int> {
  /// Creates a [GetChatsPage].
  GetChatsPage({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;
  final ChatRepository _chatRepository;

  @override
  Future<Either<Failure, List<Chat>>> call(int params) {
    return _chatRepository.getChatsPage(params);
  }
}
