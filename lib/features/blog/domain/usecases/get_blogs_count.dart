import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';

class GetBlogsCount implements UseCase<int, NoParams> {
  GetBlogsCount({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;
  final BlogRepository _blogRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _blogRepository.getBlogsCount();
  }
}
