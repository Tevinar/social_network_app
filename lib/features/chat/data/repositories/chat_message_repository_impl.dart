import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/chat/data/data_sources/chat_message_remote_data_source.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  ChatMessageRepositoryImpl({required this.chatMessageRemoteDataSource});
  final ChatMessageRemoteDataSource chatMessageRemoteDataSource;

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  ) async {
    try {
      final chatMessageModels = await chatMessageRemoteDataSource
          .getChatMessagesPage(
            pageNumber,
            chatId,
          );
      final chatMessages = chatMessageModels
          .map((chatModel) => chatModel.toEntity())
          .toList();
      return right(chatMessages);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatMessageRepositoryImpl.getChatMessagesPage',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, int>> getChatMessagesCount(String chatId) async {
    try {
      final chatMessagesCount = await chatMessageRemoteDataSource
          .getChatMessagesCount(chatId);
      return right(chatMessagesCount);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatMessageRepositoryImpl.getChatMessagesCount',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, ChatMessageChange>> watchChatMessageChanges() async* {
    try {
      await for (final ChatMessageChange chatChange
          in chatMessageRemoteDataSource.watchChatMessageChanges()) {
        yield right(chatChange);
      }
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatMessageRepositoryImpl.watchChatMessageChanges',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Any unexpected stream error is translated into a Failure
      yield left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> createChatMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      await chatMessageRemoteDataSource.postChatMessage(
        chatId: chatId,
        content: content,
      );
      return right(null);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatMessageRepositoryImpl.createChatMessage',
          error: error,
          stackTrace: stackTrace,
        );
      }
      return left(failure);
    }
  }
}
