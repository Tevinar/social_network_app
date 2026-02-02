// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:bloc_app/core/errors/failures_mapper.dart';
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
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getBlogsPage(int pageNumber) async {
    try {
      final List<BlogModel> blogs = await blogRemoteDataSource.getBlogsPage(
        pageNumber,
      );
      return right(blogs.map((blogModel) => blogModel.toEntity()).toList());
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, int>> getBlogsCount() async {
    try {
      final int blogsCount = await blogRemoteDataSource.getBlogsCount();
      return right(blogsCount);
    } catch (e) {
      return left(mapExceptionToFailure(e));
    }
  }

  @override
  Stream<Either<Failure, BlogChange>> watchBlogChanges() async* {
    try {
      await for (final blogChange in blogRemoteDataSource.watchBlogChanges()) {
        yield Right(blogChange);
      }
    } catch (error) {
      // Any unexpected stream error is translated into a Failure
      yield left(mapExceptionToFailure(error));
    }
  }
}
