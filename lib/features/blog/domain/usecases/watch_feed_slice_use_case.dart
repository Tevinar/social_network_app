import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/read_models/blog_feed_slice.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Watches one cursor-based slice of the blog feed.
class WatchFeedSliceUseCase
    implements StreamUseCase<Either<Failure, BlogFeedSlice>, String?> {
  /// Creates a [WatchFeedSliceUseCase].
  WatchFeedSliceUseCase({required this.blogRepository});

  /// Repository used to observe paged blog snapshots.
  final BlogRepository blogRepository;

  @override
  /// Starts observing the blog feed slice addressed by [cursor].
  Stream<Either<Failure, BlogFeedSlice>> call(String? cursor) {
    return blogRepository.watchBlogFeedSlice(limit: 20, cursor: cursor);
  }
}
