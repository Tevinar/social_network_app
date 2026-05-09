import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/blog/domain/read_models/blog_list_slice.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Observes the initial blog list slice with cache-first behavior.
class ObserveInitialBlogListSliceUseCase
    implements NoParamsStreamUseCase<Either<Failure, BlogListSlice>> {
  /// Creates an [ObserveInitialBlogListSliceUseCase].
  ObserveInitialBlogListSliceUseCase({required this.blogRepository});

  /// Repository used to observe paged blog snapshots.
  final BlogRepository blogRepository;

  @override
  /// Starts observing the initial blog list slice.
  Stream<Either<Failure, BlogListSlice>> call() {
    return blogRepository.observeInitialBlogListSlice(limit: 20);
  }
}
