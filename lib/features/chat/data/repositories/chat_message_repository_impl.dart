import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/errors/failures_mapper.dart';
import 'package:social_network_app/core/logging/app_logger.dart';
import 'package:social_network_app/features/chat/data/data_sources/chat_message_remote_data_source.dart';
import 'package:social_network_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_network_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_network_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:social_network_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChatMessageRepositoryImpl implements ChatMessageRepository {
  final ChatMessageRemoteDataSource chatMessageRemoteDataSource;
  ChatMessageRepositoryImpl({required this.chatMessageRemoteDataSource});

  @override
  Future<Either<Failure, List<ChatMessage>>> getChatMessagesPage(
    int pageNumber,
    String chatId,
  ) async {
    try {
      List<ChatMessageModel> chatMessageModels =
          await chatMessageRemoteDataSource.getChatMessagesPage(
            pageNumber,
            chatId,
          );
      List<ChatMessage> chatMessages = chatMessageModels
          .map((chatModel) => chatModel.toEntity())
          .toList();
      return Right(chatMessages);
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to get chat messages page',
        error: error,
        stackTrace: stackTrace,
      );
      return Left(mapExceptionToFailure(error));
    }
  }

  @override
  Future<Either<Failure, int>> getChatMessagesCount(String chatId) async {
    try {
      final int chatMessagesCount = await chatMessageRemoteDataSource
          .getChatMessagesCount(chatId);
      return right(chatMessagesCount);
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to get chat messages count',
        error: error,
        stackTrace: stackTrace,
      );
      return left(mapExceptionToFailure(error));
    }
  }

  @override
  Stream<Either<Failure, ChatMessageChange>> watchChatMessageChanges() async* {
    try {
      await for (final chatChange
          in chatMessageRemoteDataSource.watchChatMessageChanges()) {
        yield Right(chatChange);
      }
    } catch (error, stackTrace) {
      appLogger.error(
        'Failed to watch chat message changes',
        error: error,
        stackTrace: stackTrace,
      );
      // Any unexpected stream error is translated into a Failure
      yield left(mapExceptionToFailure(error));
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
      appLogger.error(
        'Failed to create chat message',
        error: error,
        stackTrace: stackTrace,
      );
      return left(mapExceptionToFailure(error));
    }
  }
}
