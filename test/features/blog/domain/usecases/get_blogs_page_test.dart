import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';
import 'package:social_app/features/blog/domain/repositories/blog_repository.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_page.dart';

class MockBlogRepository extends Mock implements BlogRepository {}

void main() {
  late MockBlogRepository blogRepository;
  late WatchBlogsPage usecase;

  final snapshot = BlogsPageSnapshot(
    pageNumber: 2,
    blogs: [
      Blog(
        id: 'blog-1',
        posterId: 'user-1',
        title: 'Title',
        content: 'Content',
        imageUrl: 'https://image',
        topics: const [BlogTopic.technology],
        updatedAt: DateTime(2025),
        posterName: 'Alice',
      ),
    ],
    source: BlogsPageSource.remote,
  );

  setUp(() {
    blogRepository = MockBlogRepository();
    usecase = WatchBlogsPage(blogRepository: blogRepository);
  });

  test(
    'given a page number when call is invoked then delegates to the repository',
    () async {
      when(
        () => blogRepository.watchBlogsPage(2),
      ).thenAnswer(
        (_) => Stream.value(right<Failure, BlogsPageSnapshot>(snapshot)),
      );

      final result = usecase(2);

      await expectLater(
        result,
        emitsInOrder([
          isA<Right<Failure, BlogsPageSnapshot>>()
              .having((value) => value.value.pageNumber, 'pageNumber', 2)
              .having(
                (value) => value.value.blogs.single.id,
                'blog id',
                'blog-1',
              ),
          emitsDone,
        ]),
      );
      verify(() => blogRepository.watchBlogsPage(2)).called(1);
    },
  );
}
