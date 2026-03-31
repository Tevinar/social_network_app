import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_page.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late GetBlogsPage usecase;

  final blogs = [
    Blog(
      id: 'blog-1',
      posterId: 'user-1',
      title: 'Title',
      content: 'Content',
      imageUrl: 'https://image',
      topics: const ['Tech'],
      updatedAt: DateTime(2025),
    ),
  ];

  setUp(() {
    blogRepository = MockBlogRepository();
    usecase = GetBlogsPage(blogRepository: blogRepository);
  });

  test(
    'given a page number when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => blogRepository.getBlogsPage(2),
      ).thenAnswer((_) async => right<Failure, List<Blog>>(blogs));

      // Act
      final result = await usecase(2);

      // Assert
      expect(result, right<Failure, List<Blog>>(blogs));
      verify(() => blogRepository.getBlogsPage(2)).called(1);
    },
  );
}
