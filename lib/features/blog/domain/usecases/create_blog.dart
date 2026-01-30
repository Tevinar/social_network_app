// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:bloc_app/core/error/failures.dart';
import 'package:bloc_app/core/usecase/usecase.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreateBlog implements UseCase<Blog, CreateBlogParams> {
  BlogRepository blogRepository;
  CreateBlog({required this.blogRepository});

  @override
  Future<Either<Failure, Blog>> call(CreateBlogParams params) {
    return blogRepository.createBlog(
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
