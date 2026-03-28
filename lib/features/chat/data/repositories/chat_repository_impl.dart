// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRemoteDataSource chatRemoteDataSource;
  ChatRepositoryImpl({required this.chatRemoteDataSource});

  @override
  Future<Either<Failure, Chat>> createChat(
    List<User> members,
    String firstMessageContent,
  ) async {
    try {
      final chat = await chatRemoteDataSource.createChat(
        members.map(UserModel.fromEntity).toList(),
        firstMessageContent,
      );
      return right(chat.toEntity());
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.createChat',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Chat>>> getChatsPage(int pageNumber) async {
    try {
      final chatModels = await chatRemoteDataSource.getChatsPage(
        pageNumber,
      );
      final chats = chatModels
          .map((chatModel) => chatModel.toEntity())
          .toList();
      return right(chats);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.getChatsPage',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }

  @override
  Future<Either<Failure, int>> getChatsCount() async {
    try {
      final chatsCount = await chatRemoteDataSource.getChatsCount();
      return right(chatsCount);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.getChatsCount',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, ChatChange>> watchChatChanges() async* {
    try {
      await for (final ChatChange chatChange
          in chatRemoteDataSource.watchChatChanges()) {
        yield right(chatChange);
      }
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.watchChatChanges',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Any unexpected stream error is translated into a Failure
      yield left(failure);
    }
  }

  @override
  Future<Either<Failure, Chat?>> getChatByMembers(List<User> members) async {
    try {
      final chatModel = await chatRemoteDataSource.getChatByMembers(
        members.map(UserModel.fromEntity).toList(),
      );
      return right(chatModel?.toEntity());
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.getChatByMembers',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }
}
