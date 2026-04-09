import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Watches a single blog by id, emitting cached data first when available.
class WatchBlogById
    implements StreamUseCase<Either<Failure, BlogSnapshot>, String> {
  /// Creates a [WatchBlogById].
  WatchBlogById(this.repository);

  /// Repository used to observe a single blog.
  final BlogRepository repository;

  @override
  Stream<Either<Failure, BlogSnapshot>> call(String blogId) {
    return repository.watchBlogById(blogId);
  }
}
