import 'package:social_network_app/core/errors/failures.dart';
import 'package:social_network_app/core/usecases/usecase.dart';
import 'package:social_network_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetBlogsCount implements UseCase<int, NoParams> {
  final BlogRepository _blogRepository;
  GetBlogsCount({required BlogRepository blogRepository})
    : _blogRepository = blogRepository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return _blogRepository.getBlogsCount();
  }
}
