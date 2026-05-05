import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/blog/domain/events/blog_feed_event.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Watches live blog feed events emitted by the backend.
class WatchFeedEventsUseCase
    implements NoParamsStreamUseCase<Either<Failure, BlogFeedEvent>> {
  /// Creates a [WatchFeedEventsUseCase].
  WatchFeedEventsUseCase({required this.blogRepository});

  /// Repository used to observe live blog feed events.
  final BlogRepository blogRepository;

  @override
  /// Starts observing backend blog feed events.
  Stream<Either<Failure, BlogFeedEvent>> call() {
    return blogRepository.watchBlogFeedEvents();
  }
}
