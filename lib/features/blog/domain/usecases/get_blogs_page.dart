import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Watches a page of blogs, emitting cached data first and remote updates next.
class WatchBlogsPage
    implements StreamUseCase<Either<Failure, BlogsPageSnapshot>, int> {
  /// Creates a [WatchBlogsPage].
  WatchBlogsPage({required this.blogRepository});

  /// Repository used to observe paged blog snapshots.
  final BlogRepository blogRepository;

  @override
  Stream<Either<Failure, BlogsPageSnapshot>> call(int pageNumber) {
    return blogRepository.watchBlogsPage(pageNumber);
  }
}
