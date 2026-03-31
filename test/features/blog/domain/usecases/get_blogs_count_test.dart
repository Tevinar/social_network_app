import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_count.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late GetBlogsCount usecase;

  setUp(() {
    blogRepository = MockBlogRepository();
    usecase = GetBlogsCount(blogRepository: blogRepository);
  });

  test(
    'given NoParams when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => blogRepository.getBlogsCount(),
      ).thenAnswer((_) async => right<Failure, int>(4));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, right<Failure, int>(4));
      verify(() => blogRepository.getBlogsCount()).called(1);
    },
  );
}
