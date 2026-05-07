import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Watches live chat-message events emitted by the backend.
class WatchChatMessageChanges
    implements NoParamsStreamUseCase<Either<Failure, ChatMessageChange>> {
  /// Creates a [WatchChatMessageChanges].
  WatchChatMessageChanges({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to observe chat-message events.
  final ChatRepository _chatRepository;

  @override
  /// Starts observing live chat-message events.
  Stream<Either<Failure, ChatMessageChange>> call() {
    return _chatRepository.watchChatMessageChanges();
  }
}
