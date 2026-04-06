import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// A get blog by ID.
class GetBlogById implements UseCase<Blog, String> {
  /// Creates a [GetBlogById].
  GetBlogById(this.repository);

  /// The blog repository.
  final BlogRepository repository;

  @override
  Future<Either<Failure, Blog>> call(String blogId) {
    return repository.getBlogById(blogId);
  }
}
