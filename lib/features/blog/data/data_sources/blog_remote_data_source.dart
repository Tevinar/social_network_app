import 'dart:io';

import 'package:dio/dio.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/exceptions_mapper.dart';
import 'package:social_app/features/blog/data/models/blog_list_slice_model.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';

/// Remote blog data source backed by the HTTP API.
abstract interface class BlogRemoteDataSource {
  /// Creates a new blog remotely and returns the persisted payload.
  Future<BlogModel> createBlog({
    required String title,
    required String content,
    required File image,
    required List<String> topics,
  });

  /// Fetches one cursor-based slice of the remote blog list.
  Future<BlogListSliceModel> getBlogListSlice({
    int limit = 20,
    String? cursor,
  });

  /// Fetches one blog by its stable identifier.
  Future<BlogModel> getBlogById(String blogId);
}

/// Default [BlogRemoteDataSource] implementation using Dio.
class BlogRemoteDataSourceImpl implements BlogRemoteDataSource {
  /// Creates a [BlogRemoteDataSourceImpl].
  const BlogRemoteDataSourceImpl({
    required Dio dio,
  }) : _dio = dio;

  final Dio _dio;

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
        throw const InvalidResponseException(
          message: 'Create blog response is empty',
        );
      }

      return BlogModel.fromJson(body);
    });
  }

  @override
  Future<BlogListSliceModel> getBlogListSlice({
    int limit = 20,
    String? cursor,
  }) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>(
        '/blogs',
        queryParameters: {
          'limit': limit,
          'cursor': ?cursor,
        },
      );

      final body = response.data;
      if (body == null) {
        throw const InvalidResponseException(
          message: 'List blogs response is empty',
        );
      }

      return BlogListSliceModel.fromJson(body);
    });
  }

  @override
  Future<BlogModel> getBlogById(String blogId) {
    return guardRemoteDataSourceCall(() async {
      final response = await _dio.get<Map<String, dynamic>>('/blogs/$blogId');

      final body = response.data;
      if (body == null) {
        throw const InvalidResponseException(
          message: 'Get blog response is empty',
        );
      }

      return BlogModel.fromJson(body);
    });
  }
}
