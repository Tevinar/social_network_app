import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Subscribes to live chat-list events emitted by the backend.
class SubscribeToChatListUseCase
    implements NoParamsStreamUseCase<Either<Failure, ChatListChange>> {
  /// Creates a [SubscribeToChatListUseCase].
  SubscribeToChatListUseCase({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to observe chat-list events.
  final ChatRepository _chatRepository;

  @override
  /// Starts observing live chat-list events.
  Stream<Either<Failure, ChatListChange>> call() {
    return _chatRepository.subscribeToChatList();
  }
}
