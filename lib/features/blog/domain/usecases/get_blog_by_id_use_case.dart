import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Retrieves one blog by its stable identifier.
class GetBlogByIdUseCase implements UseCase<Blog, String> {
  /// Creates a [GetBlogByIdUseCase].
  GetBlogByIdUseCase(this.repository);

  /// Repository used to load blog details.
  final BlogRepository repository;

  @override
  /// Loads the blog identified by [blogId].
  Future<Either<Failure, Blog>> call(String blogId) {
    return repository.getBlogById(blogId);
  }
}
