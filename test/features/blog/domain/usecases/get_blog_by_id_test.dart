import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late GetBlogById usecase;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
  );

  setUp(() {
    blogRepository = MockBlogRepository();
    usecase = GetBlogById(blogRepository);
  });

  test(
    'given a blog id when call is invoked then delegates to the repository',
    () async {
      when(
        () => blogRepository.getBlogById('blog-1'),
      ).thenAnswer((_) async => right<Failure, Blog>(blog));

      final result = await usecase('blog-1');

      expect(result, right<Failure, Blog>(blog));
      verify(() => blogRepository.getBlogById('blog-1')).called(1);
    },
  );
}
