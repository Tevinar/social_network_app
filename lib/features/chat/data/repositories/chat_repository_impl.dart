// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_app/core/errors/failures_mapper.dart';
import 'package:bloc_app/features/auth/data/models/user_model.dart';
import 'package:bloc_app/features/auth/domain/entities/user.dart';
import 'package:bloc_app/features/chat/data/models/chat_model.dart';
import 'package:fpdart/fpdart.dart';

import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRemoteDataSource chatRemoteDataSource;
  ChatRepositoryImpl({required this.chatRemoteDataSource});

  @override
  Future<Either<Failure, Chat>> createChat(
    List<User> members,
    String firstMessageContent,
  ) async {
    try {
      ChatModel chat = await chatRemoteDataSource.createChat(
        members.map((e) => UserModel.fromEntity(e)).toList(),
        firstMessageContent,
      );
      return Right(chat.toEntity());
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getChatsPage(int pageNumber) async {
    try {
      List<ChatModel> chatModels = await chatRemoteDataSource.getChatsPage(
        pageNumber,
      );
      List<Chat> chats = chatModels
          .map((chatModel) => chatModel.toEntity())
          .toList();
      return Right(chats);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> getChatsCount() async {
    try {
      final int chatsCount = await chatRemoteDataSource.getChatsCount();
      return right(chatsCount);
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }
}
