// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:bloc_app/core/constants/error_messages.dart';
import 'package:bloc_app/core/errors/exceptions.dart';
import 'package:bloc_app/core/network/connection_checker.dart';
import 'package:bloc_app/features/blog/domain/entities/blog_change.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:bloc_app/features/blog/data/models/blog_model.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/repositories/blog_repository.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  // final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;
  BlogRepositoryImpl({
    required this.blogRemoteDataSource,
    // required this.blogLocalDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<ServerFailure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(ServerFailure(ErrorMessages.noConnection));
      }
      String blogId = const Uuid().v1();
      String imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blogId: blogId,
      );

      BlogModel blogModel = BlogModel(
        id: blogId,
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: imageUrl,
        topics: topics,
        updatedAt: DateTime.now(),
      );

      final BlogModel savedBlog = await blogRemoteDataSource.postBlog(
        blogModel,
      );

      return right(savedBlog.toEntity());
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<ServerFailure, List<Blog>>> getBlogsPage(int pageNumber) async {
    try {
      final List<BlogModel> blogs = await blogRemoteDataSource.getBlogsPage(
        pageNumber,
      );
      return right(blogs.map((blogModel) => blogModel.toEntity()).toList());
    } on ArgumentError catch (e) {
      return left(ServerFailure(e.message));
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<ServerFailure, int>> getBlogsCount() async {
    try {
      final int blogsCount = await blogRemoteDataSource.getBlogsCount();
      return right(blogsCount);
    } on ServerException catch (e) {
      return left(ServerFailure(e.message));
    }
  }

  @override
  Stream<Either<ServerFailure, BlogChange>> watchBlogChanges() async* {
    try {
      await for (final blogChange in blogRemoteDataSource.watchBlogChanges()) {
        yield Right(blogChange);
      }
    } catch (error) {
      // Any unexpected stream error is translated into a Failure
      yield left(ServerFailure(error.toString()));
    }
  }
}
