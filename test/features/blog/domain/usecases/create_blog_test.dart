import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/create_blog.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late CreateBlog usecase;
  late File defaultImage;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUpAll(() {
    registerFallbackValue(File('/tmp/image.png'));
  });

  setUp(() {
    blogRepository = MockBlogRepository();
    usecase = CreateBlog(blogRepository: blogRepository);
    defaultImage = File('/tmp/image.png');
  });

  CreateBlogParams buildParams({
    File? image,
    String title = 'Title',
    String content = 'Content',
    String posterId = 'user-1',
    String posterName = 'Alice',
    List<BlogTopic> topics = const [BlogTopic.technology],
  }) {
    return CreateBlogParams(
      posterId: posterId,
      posterName: posterName,
      title: title,
      content: content,
      image: image ?? defaultImage,
      topics: topics,
    );
  }

  test(
    'given an empty image path when call is invoked then returns '
    'ValidationFailure',
    () async {
      // Act
      final result = await usecase(
        buildParams(image: File('')),
      );

      // Assert
      expect(
        result,
        left<Failure, Blog>(
          const ValidationFailure('Image cannot be empty'),
        ),
      );
      verifyNever(
        () => blogRepository.createBlog(
          image: any(named: 'image'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          posterId: any(named: 'posterId'),
          posterName: any(named: 'posterName'),
          topics: any(named: 'topics'),
        ),
      );
    },
  );

  test(
    'given an empty title when call is invoked then returns ValidationFailure',
    () async {
      // Act
      final result = await usecase(buildParams(title: ''));

      // Assert
      expect(
        result,
        left<Failure, Blog>(
          const ValidationFailure('Title cannot be empty'),
        ),
      );
    },
  );

  test(
    'given an empty content when call is invoked then returns '
    'ValidationFailure',
    () async {
      // Act
      final result = await usecase(buildParams(content: ''));

      // Assert
      expect(
        result,
        left<Failure, Blog>(
          const ValidationFailure('Content cannot be empty'),
        ),
      );
    },
  );

  test(
    'given an empty poster id when call is invoked then returns '
    'ValidationFailure',
    () async {
      // Act
      final result = await usecase(buildParams(posterId: ''));

      // Assert
      expect(
        result,
        left<Failure, Blog>(
          const ValidationFailure('Poster ID cannot be empty'),
        ),
      );
    },
  );

  test(
    'given no topics when call is invoked then returns ValidationFailure',
    () async {
      // Act
      final result = await usecase(buildParams(topics: const []));

      // Assert
      expect(
        result,
        left<Failure, Blog>(
          const ValidationFailure('At least one topic must be selected'),
        ),
      );
    },
  );

  test(
    'given valid params when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => blogRepository.createBlog(
          image: any(named: 'image'),
          title: any(named: 'title'),
          content: any(named: 'content'),
          posterId: any(named: 'posterId'),
          posterName: any(named: 'posterName'),
          topics: any(named: 'topics'),
        ),
      ).thenAnswer((_) async => right<Failure, Blog>(blog));

      // Act
      final result = await usecase(buildParams());

      // Assert
      expect(result, right<Failure, Blog>(blog));
      verify(
        () => blogRepository.createBlog(
          image: defaultImage,
          title: 'Title',
          content: 'Content',
          posterId: 'user-1',
          posterName: 'Alice',
          topics: const [BlogTopic.technology],
        ),
      ).called(1);
    },
  );
}
