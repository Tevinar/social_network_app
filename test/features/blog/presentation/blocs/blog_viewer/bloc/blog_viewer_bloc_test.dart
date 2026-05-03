import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_by_id.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_viewer/blog_viewer_bloc.dart';

class MockWatchBlogById extends Mock implements WatchBlogById {}

void main() {
  late MockWatchBlogById watchBlogById;

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
    watchBlogById = MockWatchBlogById();
  });

  test(
    'given the bloc is created when reading state then state is '
    'BlogViewerInitial',
    () {
      final bloc = BlogViewerBloc(watchBlogById: watchBlogById);
      addTearDown(bloc.close);

      expect(bloc.state, isA<BlogViewerInitial>());
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given fetching by id succeeds when LoadBlog is added then it emits '
    'loading and BlogViewerSuccess',
    build: () {
      when(() => watchBlogById(blog.id)).thenAnswer(
        (_) => Stream.value(
          right(
            BlogSnapshot(
              blog: blog,
              source: BlogSource.remote,
            ),
          ),
        ),
      );
      return BlogViewerBloc(watchBlogById: watchBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerSuccess>().having((state) => state.blog, 'blog', blog),
    ],
    verify: (_) {
      verify(() => watchBlogById(blog.id)).called(1);
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given cached blog and refresh failure when LoadBlog is added then it '
    'emits success with a refresh error',
    build: () {
      when(() => watchBlogById(blog.id)).thenAnswer(
        (_) => Stream.fromIterable([
          right(
            BlogSnapshot(
              blog: blog,
              source: BlogSource.cache,
            ),
          ),
          right(
            BlogSnapshot(
              blog: blog,
              source: BlogSource.cache,
              refreshFailure: const ValidationFailure('Blog fetch failed'),
            ),
          ),
        ]),
      );
      return BlogViewerBloc(watchBlogById: watchBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerSuccess>()
          .having((state) => state.isFromCache, 'isFromCache', isTrue)
          .having((state) => state.refreshError, 'refreshError', isNull),
      isA<BlogViewerSuccess>()
          .having((state) => state.isFromCache, 'isFromCache', isTrue)
          .having(
            (state) => state.refreshError,
            'refreshError',
            'Blog fetch failed',
          ),
    ],
    verify: (_) {
      verify(() => watchBlogById(blog.id)).called(1);
    },
  );

  blocTest<BlogViewerBloc, BlogViewerState>(
    'given fetching by id fails without cache when LoadBlog is added then it '
    'emits failure',
    build: () {
      when(() => watchBlogById(blog.id)).thenAnswer(
        (_) => Stream.value(left(const ValidationFailure('Blog fetch failed'))),
      );
      return BlogViewerBloc(watchBlogById: watchBlogById);
    },
    act: (bloc) => bloc.add(LoadBlog(blogId: blog.id)),
    expect: () => [
      isA<BlogViewerLoading>(),
      isA<BlogViewerFailure>().having(
        (state) => state.error,
        'error',
        'Blog fetch failed',
      ),
    ],
    verify: (_) {
      verify(() => watchBlogById(blog.id)).called(1);
    },
  );
}
