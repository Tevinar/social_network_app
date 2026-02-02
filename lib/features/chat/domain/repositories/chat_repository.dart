import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, Chat>> createChat(
    List<User> members,
    String firstMessageContent,
  );

  Future<Either<Failure, List<Chat>>> getChatsPage(int pageNumber);

  Future<Either<Failure, int>> getChatsCount();
}
