import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_by_id.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late WatchBlogById usecase;

  final snapshot = BlogSnapshot(
    blog: Blog(
      id: 'blog-1',
      posterId: 'user-1',
      title: 'Title',
      content: 'Content',
      imageUrl: 'https://image',
      topics: const [BlogTopic.technology],
      updatedAt: DateTime(2025),
      posterName: 'Alice',
    ),
    source: BlogSource.remote,
  );

  setUp(() {
    blogRepository = MockBlogRepository();
    usecase = WatchBlogById(blogRepository);
  });

  test(
    'given a blog id when call is invoked then delegates to the repository',
    () async {
      when(
        () => blogRepository.watchBlogById('blog-1'),
      ).thenAnswer((_) => Stream.value(right(snapshot)));

      final result = usecase('blog-1');

      await expectLater(
        result,
        emitsInOrder([
          isA<Right<Failure, BlogSnapshot>>().having(
            (value) => value.value.blog.id,
            'blog id',
            'blog-1',
          ),
          emitsDone,
        ]),
      );
      verify(() => blogRepository.watchBlogById('blog-1')).called(1);
    },
  );
}
