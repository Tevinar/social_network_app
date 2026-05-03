import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/core/network/sse/sse_client.dart';
import 'package:social_app/features/blog/data/models/blog_feed_event_model.dart';
import 'package:social_app/features/blog/data/models/blog_feed_slice_model.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';

/// Remote blog data source backed by the HTTP API and SSE feed endpoints.
abstract interface class BlogRemoteDataSource {
  /// Creates a new blog remotely and returns the persisted payload.
  Future<BlogModel> createBlog({
    required String title,
    required String content,
    required File image,
    required List<String> topics,
  });

  /// Fetches one cursor-based slice of the remote blog feed.
  Future<BlogFeedSliceModel> getBlogFeedSlice({
    int limit = 20,
    String? cursor,
  });

  /// Fetches one blog by its stable identifier.
  Future<BlogModel> getBlogById(String blogId);

  /// Opens the remote Server-Sent Events stream of blog feed events.
  Stream<BlogFeedEventModel> watchBlogFeedEvents();
}

/// Default [BlogRemoteDataSource] implementation using Dio and a generic SSE
/// client.
class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  /// Creates a [BlogRemoteDataSourceImpl].
  const BlogRemoteDataSourceImpl({
    required Dio dio,
    required SseClient sseClient,
  }) : _dio = dio,
       _sseClient = sseClient;

  final Dio _dio;
  final SseClient _sseClient;

  @override
  Future<BlogModel> createBlog({
    required String title,
    required String content,
    required File image,
    required List<String> topics,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.post<Map<String, dynamic>>(
        '/blogs',
        data: FormData.fromMap({
          'title': title,
          'content': content,
          'topics': topics,
          'image': await MultipartFile.fromFile(
            image.path,
          ),
        }),
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(message: 'Create blog response is empty');
      }

      return BlogModel.fromJson(body);
    });
  }

  @override
  Future<BlogFeedSliceModel> getBlogFeedSlice({
    int limit = 20,
    String? cursor,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/blogs',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const ServerException(message: 'List blogs response is empty');
      }

      return BlogFeedSliceModel.fromJson(body);
    });
  }

  @override
  Future<BlogModel> getBlogById(String blogId) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/blogs/$blogId');

      final body = response.data;
      if (body == null) {
        throw const ServerException(message: 'Get blog response is empty');
      }

      return BlogModel.fromJson(body);
    });
  }

  @override
  Stream<BlogFeedEventModel> watchBlogFeedEvents() {
    return _sseClient
        .connect('/blogs/events')
        .map(BlogFeedEventModel.fromSseEvent);
  }
}
