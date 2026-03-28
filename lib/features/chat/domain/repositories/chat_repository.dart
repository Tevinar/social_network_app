import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';

/// A chat repository.
abstract interface class ChatRepository {
  /// Create chat.
  Future<Either<Failure, Chat>> createChat(
    List<User> members,
    String firstMessageContent,
  );

  /// Gets the chats page.
  Future<Either<Failure, List<Chat>>> getChatsPage(int pageNumber);

  /// Gets the chats count.
  Future<Either<Failure, int>> getChatsCount();

  /// Returns the watch chat changes stream.
  Stream<Either<Failure, ChatChange>> watchChatChanges();

  /// Gets the chat by members.
  Future<Either<Failure, Chat?>> getChatByMembers(List<User> members);
}
