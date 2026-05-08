import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_candidate_list_slice.dart';
import 'package:social_app/features/chat/domain/pagination/chat_list_slice.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_list_slice.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/results/chat_write_result.dart';

/// Repository implementation that maps remote chat payloads to domain entities.
class ChatRepositoryImpl implements ChatRepository {
  /// Creates a [ChatRepositoryImpl].
  ChatRepositoryImpl({required this.chatRemoteDataSource});

  /// Remote data source used for chat persistence and realtime updates.
  final ChatRemoteDataSource chatRemoteDataSource;

  @override
  Future<Either<Failure, ChatCandidateListSlice>> getChatCandidateListSlice({
    required int limit,
    String? cursor,
  }) async {
    try {
      final sliceModel = await chatRemoteDataSource.getChatCandidateListSlice(
        limit: limit,
        cursor: cursor,
      );
      return right(sliceModel.toSlice());
    } on Exception catch (error, stackTrace) {
      return _mapFailure(
        error,
        stackTrace,
        'Unexpected error in ChatRepositoryImpl.getChatCandidateListSlice',
      );
    }
  }

  @override
  Future<Either<Failure, ChatWriteResult>> createChat({
    required List<String> memberIds,
    required String firstMessageContent,
  }) async {
    try {
      final resultModel = await chatRemoteDataSource.createChat(
        memberIds: memberIds,
        firstMessageContent: firstMessageContent,
      );
      return right(
        resultModel.toResult(),
      );
    } on Exception catch (error, stackTrace) {
      return _mapFailure(
        error,
        stackTrace,
        'Unexpected error in ChatRepositoryImpl.createChat',
      );
    }
  }

  @override
  Future<Either<Failure, ChatListSlice>> getChatListSlice({
    required int limit,
    String? cursor,
  }) async {
    try {
      final sliceModel = await chatRemoteDataSource.getChatListSlice(
        limit: limit,
        cursor: cursor,
      );
      return right(sliceModel.toSlice());
    } on Exception catch (error, stackTrace) {
      return _mapFailure(
        error,
        stackTrace,
        'Unexpected error in ChatRepositoryImpl.getChatListSlice',
      );
    }
  }

  @override
  Stream<Either<Failure, ChatListChange>> subscribeToChatList() async* {
    try {
      await for (final eventModel
          in chatRemoteDataSource.subscribeToChatList()) {
        yield right(eventModel.toEvent());
      }
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);
      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.subscribeToChatList',
          error: error,
          stackTrace: stackTrace,
        );
      }
      yield left(failure);
    }
  }

  @override
  Future<Either<Failure, Chat?>> getChatByMembers({
    required List<String> memberIds,
  }) async {
    try {
      final chatModel = await chatRemoteDataSource.getChatByMembers(
        memberIds: memberIds,
      );
      return right(chatModel?.toEntity());
    } on Exception catch (error, stackTrace) {
      return _mapFailure(
        error,
        stackTrace,
        'Unexpected error in ChatRepositoryImpl.getChatByMembers',
      );
    }
  }

  @override
  Future<Either<Failure, ChatMessageListSlice>> getChatMessageListSlice({
    required String chatId,
    required int limit,
    String? cursor,
  }) async {
    try {
      final sliceModel = await chatRemoteDataSource.getChatMessageListSlice(
        chatId: chatId,
        limit: limit,
        cursor: cursor,
      );
      return right(sliceModel.toSlice());
    } on Exception catch (error, stackTrace) {
      return _mapFailure(
        error,
        stackTrace,
        'Unexpected error in ChatRepositoryImpl.getChatMessageListSlice',
      );
    }
  }

  @override
  Future<Either<Failure, ChatWriteResult>> createChatMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final resultModel = await chatRemoteDataSource.createChatMessage(
        chatId: chatId,
        content: content,
      );
      return right(
        resultModel.toResult(),
      );
    } on Exception catch (error, stackTrace) {
      return _mapFailure(
        error,
        stackTrace,
        'Unexpected error in ChatRepositoryImpl.createChatMessage',
      );
    }
  }

  @override
  Stream<Either<Failure, ChatMessageListChange>> subscribeToChatMessageList({
    required String chatId,
  }) async* {
    try {
      await for (final eventModel
          in chatRemoteDataSource.subscribeToChatMessageList(chatId: chatId)) {
        yield right(eventModel.toEvent());
      }
    } on Exception catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);
      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in ChatRepositoryImpl.subscribeToChatMessageList',
          error: error,
          stackTrace: stackTrace,
        );
      }
      yield left(failure);
    }
  }

  Either<Failure, T> _mapFailure<T>(
    Exception error,
    StackTrace stackTrace,
    String message,
  ) {
    final failure = mapExceptionToFailure(error);

    if (failure is UnexpectedFailure) {
      appLogger.error(
        message,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return left(failure);
  }
}
