// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateBlog implements UseCase<Blog, CreateBlogParams> {
  final BlogRepository _blogRepository;
  CreateBlog({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;

  @override
  Future<Either<Failure, Blog>> call(CreateBlogParams params) async {
    if (params.image.path.isEmpty) {
      return left(const ValidationFailure('Image cannot be empty'));
    }
    if (params.title.isEmpty) {
      return left(const ValidationFailure('Title cannot be empty'));
    }
    if (params.content.isEmpty) {
      return left(const ValidationFailure('Content cannot be empty'));
    }
    if (params.posterId.isEmpty) {
      return left(const ValidationFailure('Poster ID cannot be empty'));
    }
    if (params.topics.isEmpty) {
      return left(
        const ValidationFailure('At least one topic must be selected'),
      );
    }

    return _blogRepository.createBlog(
      image: params.image,
      title: params.title,
      content: params.content,
      posterId: params.posterId,
      topics: params.topics,
    );
  }
}

class CreateBlogParams {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;

  CreateBlogParams({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}
