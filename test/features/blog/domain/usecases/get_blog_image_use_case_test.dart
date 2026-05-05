import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_image_use_case.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late GetBlogImageUseCase useCase;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Blog title',
    content: 'Blog content',
    imageUrl: 'https://example.com/blog-1.png',
    topics: [BlogTopic.technology],
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 2),
    posterName: 'Test User',
  );

  final imageFile = File('${Directory.systemTemp.path}/blog-image-test.img');

  setUp(() {
    blogRepository = MockBlogRepository();
    useCase = GetBlogImageUseCase(blogRepository: blogRepository);
  });

  test(
    'given a blog when call is invoked then delegates to the repository',
    () async {
      when(
        () => blogRepository.getBlogImage(blog),
      ).thenAnswer((_) async => right(imageFile));

      final result = await useCase(blog);

      expect(
        result,
        isA<Right<Failure, File?>>().having(
          (value) => value.value,
          'image file',
          imageFile,
        ),
      );
      verify(() => blogRepository.getBlogImage(blog)).called(1);
    },
  );
}
