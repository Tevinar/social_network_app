import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failure_messages.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_case_interfaces/use_case.dart';
import 'package:social_app/features/blog/domain/read_models/blog_list_slice.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// Loads one cursor-based blog list slice as a one-shot request.
class GetBlogListSliceUseCase
    implements UseCase<BlogListSlice, GetBlogListSliceParams> {
  /// Creates a [GetBlogListSliceUseCase].
  GetBlogListSliceUseCase({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;

  /// Repository used to load remote list slices.
  final BlogRepository _blogRepository;

  @override
  /// Validates the requested slice size, then loads the list slice.
  Future<Either<Failure, BlogListSlice>> call(
    GetBlogListSliceParams params,
  ) {
    if (params.limit <= 0) {
      return Future.value(
        left(const ValidationFailure(CommonFailureMessages.invalidLimit)),
      );
    }

    return _blogRepository.getBlogListSlice(
      limit: params.limit,
      cursor: params.cursor,
    );
  }
}

/// Parameters required to load one blog-list slice.
class GetBlogListSliceParams {
  /// Creates a [GetBlogListSliceParams].
  const GetBlogListSliceParams({
    required this.limit,
    this.cursor,
  });

  /// Maximum number of blogs to return.
  final int limit;

  /// Opaque cursor of the next slice to load.
  final String? cursor;
}
