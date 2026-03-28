import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

/// A get blogs page widget.
class GetBlogsPage implements UseCase<List<Blog>, int> {
  /// Creates a [GetBlogsPage].
  GetBlogsPage({required this.blogRepository});

  /// The blog repository.
  BlogRepository blogRepository;

  @override
  Future<Either<Failure, List<Blog>>> call(int pageNumber) {
    return blogRepository.getBlogsPage(pageNumber);
  }
}
