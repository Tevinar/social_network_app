import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Validates blog input data and delegates blog creation to the repository.
class CreateBlog implements UseCase<Blog, CreateBlogParams> {
  /// Creates a [CreateBlog].
  CreateBlog({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;

  /// Repository used to persist the new blog.
  final BlogRepository _blogRepository;

  @override
  /// Validates the request, then creates the blog if the data is valid.
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

/// Parameters required to create a new blog post.
class CreateBlogParams {
  /// Creates a [CreateBlogParams].
  CreateBlogParams({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });

  /// Identifier of the user creating the blog.
  final String posterId;

  /// Blog title.
  final String title;

  /// Blog content body.
  final String content;

  /// Selected cover image file.
  final File image;

  /// Selected topics attached to the blog.
  final List<String> topics;
}
