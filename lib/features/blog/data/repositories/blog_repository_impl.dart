// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/errors/failures_mapper.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  BlogRepositoryImpl({required this.blogRemoteDataSource});

  @override
  Future<Either<Failure, Blog>> createBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      final blogId = const Uuid().v1();
      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
        image: image,
        blogId: blogId,
      );

      final blogModel = BlogModel(
        id: blogId,
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: imageUrl,
        topics: topics,
        updatedAt: DateTime.now(),
      );

      final savedBlog = await blogRemoteDataSource.postBlog(
        blogModel,
      );

      return right(savedBlog.toEntity());
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.createBlog',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getBlogsPage(int pageNumber) async {
    try {
      final blogs = await blogRemoteDataSource.getBlogsPage(
        pageNumber,
      );
      return right(blogs.map((blogModel) => blogModel.toEntity()).toList());
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogsPage',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Future<Either<Failure, int>> getBlogsCount() async {
    try {
      final blogsCount = await blogRemoteDataSource.getBlogsCount();
      return right(blogsCount);
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.getBlogsCount',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return left(failure);
    }
  }

  @override
  Stream<Either<Failure, BlogChange>> watchBlogChanges() async* {
    try {
      await for (final BlogChange blogChange
          in blogRemoteDataSource.watchBlogChanges()) {
        yield right(blogChange);
      }
    } catch (error, stackTrace) {
      final failure = mapExceptionToFailure(error);

      if (failure is UnexpectedFailure) {
        appLogger.error(
          'Unexpected error in BlogRepositoryImpl.watchBlogChanges',
          error: error,
          stackTrace: stackTrace,
        );
      }
      // Any unexpected stream error is translated into a Failure
      yield left(mapExceptionToFailure(error));
    }
  }
}
