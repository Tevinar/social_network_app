import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Watches live chat-feed events emitted by the backend.
class WatchChatFeedEvents
    implements NoParamsStreamUseCase<Either<Failure, ChatChange>> {
  /// Creates a [WatchChatFeedEvents].
  WatchChatFeedEvents({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to observe chat-feed events.
  final ChatRepository _chatRepository;

  @override
  /// Starts observing live chat-feed events.
  Stream<Either<Failure, ChatChange>> call() {
    return _chatRepository.watchChatFeedEvents();
  }
}
