import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Retrieves the locally cached or downloaded image file for a blog.
class GetBlogImageUseCase implements UseCase<File?, Blog> {
  /// Creates a [GetBlogImageUseCase].
  GetBlogImageUseCase({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;

  final BlogRepository _blogRepository;

  @override
  /// Loads the image associated with [blog].
  Future<Either<Failure, File?>> call(Blog blog) {
    return _blogRepository.getBlogImage(blog);
  }
}
