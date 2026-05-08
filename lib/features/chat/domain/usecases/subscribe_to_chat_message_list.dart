import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Subscribes to live chat-message events for one chat.
class SubscribeToChatMessageList
    implements
        StreamUseCase<
          Either<Failure, ChatMessageListChange>,
          SubscribeToChatMessageListParams
        > {
  /// Creates a [SubscribeToChatMessageList].
  SubscribeToChatMessageList({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  /// Repository used to observe chat-message events.
  final ChatRepository _chatRepository;

  @override
  /// Starts observing live chat-message events for one chat.
  Stream<Either<Failure, ChatMessageListChange>> call(
    SubscribeToChatMessageListParams params,
  ) {
    return _chatRepository.subscribeToChatMessageList(chatId: params.chatId);
  }
}

/// Parameters required to subscribe to one chat-message list.
class SubscribeToChatMessageListParams {
  /// Creates a [SubscribeToChatMessageListParams].
  const SubscribeToChatMessageListParams({required this.chatId});

  /// Identifier of the chat whose message events should be observed.
  final String chatId;
}
