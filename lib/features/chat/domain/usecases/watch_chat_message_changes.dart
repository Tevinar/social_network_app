import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_cases/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

/// Watches chat message changes.
class WatchChatMessageChanges
    implements StreamUseCase<Either<Failure, ChatMessageChange>, NoParams> {
  /// Creates a [WatchChatMessageChanges].
  WatchChatMessageChanges({
    required ChatMessageRepository chatMessageRepository,
  }) : _chatMessageRepository = chatMessageRepository;

  final ChatMessageRepository _chatMessageRepository;

  @override
  Stream<Either<Failure, ChatMessageChange>> call(NoParams params) {
    return _chatMessageRepository.watchChatMessageChanges();
  }
}
