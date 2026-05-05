import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Watches chat changes.
class WatchChatChanges
    implements StreamUseCase<Either<Failure, ChatChange>, NoParams> {
  /// Creates a [WatchChatChanges].
  WatchChatChanges({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  final ChatRepository _chatRepository;

  @override
  Stream<Either<Failure, ChatChange>> call(NoParams params) {
    return _chatRepository.watchChatChanges();
  }
}
