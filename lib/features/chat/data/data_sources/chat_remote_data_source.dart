import 'dart:async';

import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';
import 'package:social_app/features/chat/data/models/events/chat_feed_event_model.dart';
import 'package:social_app/features/chat/data/models/events/chat_message_event_model.dart';
import 'package:social_app/features/chat/data/models/results/chat_write_result_model.dart';
import 'package:social_app/features/chat/data/models/pagination/chat_candidates_slice_model.dart';
import 'package:social_app/features/chat/data/models/pagination/chat_feed_slice_model.dart';
import 'package:social_app/features/chat/data/models/pagination/chat_message_feed_slice_model.dart';

/// Remote data source contract for all chat-related backend calls.
abstract interface class ChatRemoteDataSource {
  /// Fetches one cursor-based slice of chat candidates.
  Future<ChatCandidatesSliceModel> getChatCandidatesSlice({
    required int limit,
    String? cursor,
  });

  /// Creates a new chat with its first message.
  Future<ChatWriteResultModel> createChat({
    required List<String> memberIds,
    required String firstMessageContent,
  });

  /// Fetches one cursor-based slice of chats ordered by recent activity.
  Future<ChatFeedSliceModel> getChatFeedSlice({
    required int limit,
    String? cursor,
  });

  /// Opens the realtime chat-feed event stream.
  Stream<ChatFeedEventModel> watchChatFeedEvents();

  /// Looks up one existing chat by its exact member set.
  /// The current user is implicitly included in the member set.
  /// Passing it explicitly is optional but allowed for convenience.
  Future<ChatModel?> getChatByMembers({
    required List<String> memberIds,
  });

  /// Fetches one cursor-based slice of messages inside the target chat.
  Future<ChatMessageFeedSliceModel> getChatMessageFeedSlice({
    required String chatId,
    required int limit,
    String? cursor,
  });

  /// Creates one new message inside the target chat.
  Future<ChatWriteResultModel> createChatMessage({
    required String chatId,
    required String content,
  });

  /// Opens the realtime chat-message event stream.
  Stream<ChatMessageEventModel> watchChatMessageChanges();
}

/// Default [ChatRemoteDataSource] implementation backed by the HTTP API and
/// SSE chat endpoints.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  /// Creates a [ChatRemoteDataSourceImpl].
  const ChatRemoteDataSourceImpl({
    required Dio dio,
    required SseClient sseClient,
  }) : _dio = dio,
       _sseClient = sseClient;

  final Dio _dio;
  final SseClient _sseClient;

  @override
  Future<ChatCandidatesSliceModel> getChatCandidatesSlice({
    required int limit,
    String? cursor,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/chats/candidates',
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(
          message: 'Chat candidates slice response body is null',
        );
      }

      return ChatCandidatesSliceModel.fromJson(body);
    });
  }

  @override
  Future<ChatWriteResultModel> createChat({
    required List<String> memberIds,
    required String firstMessageContent,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chats',
        data: {
          'members': memberIds,
          'firstMessageContent': firstMessageContent,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(
          message: 'Create chat response body is null',
        );
      }

      return ChatWriteResultModel.fromCreateChatJson(body);
    });
  }

  @override
  Future<ChatFeedSliceModel> getChatFeedSlice({
    required int limit,
    String? cursor,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/chats',
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(
          message: 'Chat feed slice response body is null',
        );
      }

      return ChatFeedSliceModel.fromJson(body);
    });
  }

  @override
  Stream<ChatFeedEventModel> watchChatFeedEvents() {
    return _sseClient
        .connect('/chats/feed/events')
        .map(ChatFeedEventModel.fromSseEvent);
  }

  @override
  Future<ChatModel?> getChatByMembers({
    required List<String> memberIds,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Object?>(
        '/chats/by-members',
        queryParameters: {
          'members': memberIds.join(','),
        },
      );

      final body = response.data;
      if (body == null) {
        return null;
      }

      if (body is! Map<String, dynamic>) {
        throw const ServerException(
          message: 'Get chat by members response body has an invalid shape',
        );
      }

      return ChatModel.fromJson(body);
    });
  }

  @override
  Future<ChatMessageFeedSliceModel> getChatMessageFeedSlice({
    required String chatId,
    required int limit,
    String? cursor,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(
          message: 'Chat message feed slice response body is null',
        );
      }

      return ChatMessageFeedSliceModel.fromJson(body);
    });
  }

  @override
  Future<ChatWriteResultModel> createChatMessage({
    required String chatId,
    required String content,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chats/$chatId/messages',
        data: {
          'content': content,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(
          message: 'Create chat message response body is null',
        );
      }

      return ChatWriteResultModel.fromCreateChatMessageJson(body);
    });
  }

  @override
  Stream<ChatMessageEventModel> watchChatMessageChanges() {
    return _sseClient
        .connect('/chats/messages/events')
        .map(ChatMessageEventModel.fromSseEvent);
  }
}
