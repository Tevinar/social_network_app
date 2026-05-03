import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';

/// Repository implementation that maps chat data source results
/// to domain types.
class ChatRepositoryImpl implements ChatRepository {
  /// Creates a [ChatRepositoryImpl].
  ChatRepositoryImpl({required this.chatRemoteDataSource});

  /// Remote data source used for chat persistence and realtime updates.
  final ChatRemoteDataSource chatRemoteDataSource;

  @override
  /// Creates a chat from domain members and returns the created domain chat.
  Future<Either<Failure, Chat>> createChat(
    List<UserEntity> members,
    String firstMessageContent,
  ) async {
    try {
      final chat = await chatRemoteDataSource.createChat(
        members.map(UserModel.fromEntity).toList(),
        firstMessageContent,
      );
      return right(chat.toEntity());
    } on Exception catch (error, stackTrace) {
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
  /// Fetches a page of chats and maps the models to domain entities.
  Future<Either<Failure, List<Chat>>> getChatsPage(int pageNumber) async {
    try {
      final chatModels = await chatRemoteDataSource.getChatsPage(
        pageNumber,
      );
      final chats = chatModels
          .map((chatModel) => chatModel.toEntity())
          .toList();
      return right(chats);
    } on Exception catch (error, stackTrace) {
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
  /// Fetches the total number of chats available in the backend.
  Future<Either<Failure, int>> getChatsCount() async {
    try {
      final chatsCount = await chatRemoteDataSource.getChatsCount();
      return right(chatsCount);
    } on Exception catch (error, stackTrace) {
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
  /// Streams realtime chat changes mapped to domain-level change objects.
  Stream<Either<Failure, ChatChange>> watchChatChanges() async* {
    try {
      await for (final ChatChange chatChange
          in chatRemoteDataSource.watchChatChanges()) {
        yield right(chatChange);
      }
    } on Exception catch (error, stackTrace) {
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
  /// Looks up an existing chat for the provided member set.
  Future<Either<Failure, Chat?>> getChatByMembers(
    List<UserEntity> members,
  ) async {
    try {
      final chatModel = await chatRemoteDataSource.getChatByMembers(
        members.map(UserModel.fromEntity).toList(),
      );
      return right(chatModel?.toEntity());
    } on Exception catch (error, stackTrace) {
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
