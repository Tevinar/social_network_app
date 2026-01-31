import 'package:bloc_app/core/errors/failure.dart';
import 'package:bloc_app/core/usecases/usecase.dart';
import 'package:bloc_app/features/blog/domain/entities/blog.dart';
import 'package:bloc_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetBlogsPage implements UseCase<List<Blog>, int> {
  BlogRepository blogRepository;
  GetBlogsPage({required this.blogRepository});

  @override
  Future<Either<Failure, List<Blog>>> call(int pageNumber) {
    return blogRepository.getBlogsPage(pageNumber);
  }
}
