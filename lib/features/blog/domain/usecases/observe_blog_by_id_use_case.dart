import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Observes one blog by its stable identifier.
class ObserveBlogByIdUseCase
    implements StreamUseCase<Either<Failure, Blog>, String> {
  /// Creates an [ObserveBlogByIdUseCase].
  ObserveBlogByIdUseCase(this.repository);

  /// Repository used to load and refresh blog details.
  final BlogRepository repository;

  @override
  /// Starts observing the blog identified by [blogId].
  Stream<Either<Failure, Blog>> call(String blogId) {
    return repository.observeBlogById(blogId);
  }
}
