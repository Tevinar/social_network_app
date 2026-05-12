import 'dart:async';

import 'package:dio/dio.dart';
import 'package:social_app/app/network/http_sse_client.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/chat/data/models/common/chat_model.dart';
import 'package:social_app/features/chat/data/models/events/chat_list_event_model.dart';
import 'package:social_app/features/chat/data/models/events/chat_message_list_event_model.dart';
import 'package:social_app/features/chat/data/models/pagination/chat_candidate_list_slice_model.dart';
import 'package:social_app/features/chat/data/models/pagination/chat_list_slice_model.dart';
import 'package:social_app/features/chat/data/models/pagination/chat_message_list_slice_model.dart';
import 'package:social_app/features/chat/data/models/results/chat_write_result_model.dart';

/// Remote data source contract for all chat-related backend calls.
abstract interface class ChatRemoteDataSource {
  /// Fetches one cursor-based slice of chat candidates.
  Future<ChatCandidateListSliceModel> getChatCandidateListSlice({
    required int limit,
    String? cursor,
  });

  /// Creates a new chat with its first message.
  Future<ChatWriteResultModel> createChat({
    required List<String> memberIds,
    required String firstMessageContent,
  });

  /// Fetches one cursor-based slice of chats ordered by recent activity.
  Future<ChatListSliceModel> getChatListSlice({
    required int limit,
    String? cursor,
  });

  /// Opens the realtime chat-list event stream.
  Stream<ChatListEventModel> subscribeToChatList();

  /// Looks up one existing chat by its exact member set.
  /// The current user is implicitly included in the member set.
  /// Passing it explicitly is optional but allowed for convenience.
  Future<ChatModel?> getChatByMembers({
    required List<String> memberIds,
  });

  /// Fetches one cursor-based slice of messages inside the target chat.
  Future<ChatMessageListSliceModel> getChatMessageListSlice({
    required String chatId,
    required int limit,
    String? cursor,
  });

  /// Creates one new message inside the target chat.
  Future<ChatWriteResultModel> createChatMessage({
    required String chatId,
    required String content,
  });

  /// Opens the realtime chat-message event stream for one chat.
  Stream<ChatMessageListEventModel> subscribeToChatMessageList({
    required String chatId,
  });
}

/// Default [ChatRemoteDataSource] implementation backed by the HTTP API and
/// SSE chat endpoints.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  /// Creates a [ChatRemoteDataSourceImpl].
  const ChatRemoteDataSourceImpl({
    required Dio dio,
    required HttpSseClient sseClient,
  }) : _dio = dio,
       _sseClient = sseClient;

  final Dio _dio;
  final HttpSseClient _sseClient;

  @override
  Future<ChatCandidateListSliceModel> getChatCandidateListSlice({
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

      return ChatCandidateListSliceModel.fromJson(body);
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
  Future<ChatListSliceModel> getChatListSlice({
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
          message: 'Chat list slice response body is null',
        );
      }

      return ChatListSliceModel.fromJson(body);
    });
  }

  @override
  Stream<ChatListEventModel> subscribeToChatList() {
    return _sseClient
        .connect('/chats/events')
        .map(ChatListEventModel.fromSseEvent);
  }

  @override
  Future<ChatModel?> getChatByMembers({
    required List<String> memberIds,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>?>(
        '/chats/by-members',
        queryParameters: {
          'members': memberIds.join(','),
        },
      );

      final body = response.data;
      if (body == null) {
        return null;
      }

      return ChatModel.fromJson(body);
    });
  }

  @override
  Future<ChatMessageListSliceModel> getChatMessageListSlice({
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
          message: 'Chat message list slice response body is null',
        );
      }

      return ChatMessageListSliceModel.fromJson(body);
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
  Stream<ChatMessageListEventModel> subscribeToChatMessageList({
    required String chatId,
  }) {
    return _sseClient
        .connect('/chats/$chatId/messages/events')
        .map(ChatMessageListEventModel.fromSseEvent);
  }
}
