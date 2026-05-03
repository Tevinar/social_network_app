import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_changes.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late WatchBlogChanges watchBlogChanges;

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

  setUp(() {
    blogRepository = MockBlogRepository();
    watchBlogChanges = WatchBlogChanges(blogRepository: blogRepository);
  });

  test(
    'given the use case is called when the repository emits blog changes then '
    'it forwards the stream',
    () async {
      final change = BlogInserted(blog);

      when(() => blogRepository.watchBlogChanges()).thenAnswer(
        (_) => Stream.value(right<Failure, BlogChange>(change)),
      );

      final emissions = await watchBlogChanges(const NoParams()).toList();

      expect(emissions, [right<Failure, BlogChange>(change)]);
      verify(() => blogRepository.watchBlogChanges()).called(1);
    },
  );
}
