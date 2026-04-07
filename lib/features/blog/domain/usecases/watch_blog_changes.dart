import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Watches blog changes.
class WatchBlogChanges
    implements StreamUseCase<Either<Failure, BlogChange>, NoParams> {
  /// Creates a [WatchBlogChanges].
  WatchBlogChanges({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;

  final BlogRepository _blogRepository;

  @override
  Stream<Either<Failure, BlogChange>> call(NoParams params) {
    return _blogRepository.watchBlogChanges();
  }
}
