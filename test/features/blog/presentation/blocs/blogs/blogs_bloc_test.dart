import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_count.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_page.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_changes.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/blogs_bloc.dart';

class MockWatchBlogsPage extends Mock implements WatchBlogsPage {}

class MockGetBlogsCount extends Mock implements GetBlogsCount {}

class MockWatchBlogChanges extends Mock implements WatchBlogChanges {}

void main() {
  late MockWatchBlogsPage watchBlogsPage;
  late MockGetBlogsCount getBlogsCount;
  late MockWatchBlogChanges watchBlogChanges;
  late StreamController<Either<Failure, BlogChange>> blogChangeController;

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
  final updatedBlog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Updated title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025, 1, 2),
    posterName: 'Alice',
  );
  final blog2 = Blog(
    id: 'blog-2',
    posterId: 'user-2',
    title: 'Second',
    content: 'More content',
    imageUrl: 'https://image-2',
    topics: const [BlogTopic.business],
    updatedAt: DateTime(2025, 1, 3),
    posterName: 'Bob',
  );

  Future<void> flushBloc() async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    watchBlogsPage = MockWatchBlogsPage();
    getBlogsCount = MockGetBlogsCount();
    watchBlogChanges = MockWatchBlogChanges();
    blogChangeController = StreamController<Either<Failure, BlogChange>>();

    when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
    when(
      () => watchBlogsPage(any()),
    ).thenAnswer(
      (_) => const Stream<Either<Failure, BlogsPageSnapshot>>.empty(),
    );
    when(() => watchBlogChanges(any())).thenAnswer(
      (_) => blogChangeController.stream,
    );
  });

  tearDown(() async {
    await blogChangeController.close();
  });

  test(
    'given the bloc is created when reading state then state is BlogsLoading',
    () {
      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      expect(bloc.state, isA<BlogsLoading>());
    },
  );

  test(
    'given cached and remote snapshots when loading the first page then '
    'remote data replaces the cached page without duplicates',
    () async {
      final controller = StreamController<Either<Failure, BlogsPageSnapshot>>();
      addTearDown(controller.close);

      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(2));
      when(() => watchBlogsPage(1)).thenAnswer((_) => controller.stream);

      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await flushBloc();

      controller
        ..add(
          right(
            BlogsPageSnapshot(
              pageNumber: 1,
              blogs: [blog],
              source: BlogsPageSource.cache,
            ),
          ),
        )
        ..add(
          right(
            BlogsPageSnapshot(
              pageNumber: 1,
              blogs: [blog2],
              source: BlogsPageSource.remote,
            ),
          ),
        );

      await flushBloc();

      expect(emittedStates, hasLength(4));
      expect(emittedStates[0], isA<BlogsLoading>());
      expect(emittedStates[1], isA<BlogsLoading>());
      expect(
        emittedStates[2],
        isA<BlogsSuccess>()
            .having(
              (state) => state.blogs.map((blog) => blog.id).toList(),
              'blog ids',
              ['blog-1'],
            )
            .having((state) => state.pageNumber, 'pageNumber', 2),
      );
      expect(
        emittedStates[3],
        isA<BlogsSuccess>()
            .having(
              (state) => state.blogs.map((blog) => blog.id).toList(),
              'blog ids',
              ['blog-2'],
            )
            .having((state) => state.pageNumber, 'pageNumber', 2),
      );
    },
  );

  test(
    'given no cached data when the page stream fails then it emits '
    'BlogsFailure',
    () async {
      final controller = StreamController<Either<Failure, BlogsPageSnapshot>>();
      addTearDown(controller.close);

      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(2));
      when(() => watchBlogsPage(1)).thenAnswer((_) => controller.stream);

      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await flushBloc();

      controller.add(left(const ValidationFailure('boom')));
      await flushBloc();

      expect(
        emittedStates.last,
        isA<BlogsFailure>().having((state) => state.error, 'error', 'boom'),
      );
    },
  );

  test(
    'given cached data and a refresh failure when the page stream emits then '
    'the bloc keeps cached blogs in the failure state',
    () async {
      final controller = StreamController<Either<Failure, BlogsPageSnapshot>>();
      addTearDown(controller.close);

      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(2));
      when(() => watchBlogsPage(1)).thenAnswer((_) => controller.stream);

      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await flushBloc();

      controller
        ..add(
          right(
            BlogsPageSnapshot(
              pageNumber: 1,
              blogs: [blog],
              source: BlogsPageSource.cache,
            ),
          ),
        )
        ..add(
          right(
            BlogsPageSnapshot(
              pageNumber: 1,
              blogs: [blog],
              source: BlogsPageSource.cache,
              refreshFailure: const ValidationFailure('stale'),
            ),
          ),
        );

      await flushBloc();

      expect(
        emittedStates.last,
        isA<BlogsFailure>()
            .having((state) => state.error, 'error', 'stale')
            .having(
              (state) => state.blogs.map((blog) => blog.id).toList(),
              'blog ids',
              ['blog-1'],
            )
            .having((state) => state.pageNumber, 'pageNumber', 2),
      );
    },
  );

  test(
    'given a blog insert event when handled then it prepends the inserted blog',
    () async {
      final controller = StreamController<Either<Failure, BlogsPageSnapshot>>();
      addTearDown(controller.close);

      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(1));
      when(() => watchBlogsPage(1)).thenAnswer((_) => controller.stream);

      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await flushBloc();
      controller.add(
        right(
          BlogsPageSnapshot(
            pageNumber: 1,
            blogs: [blog2],
            source: BlogsPageSource.remote,
          ),
        ),
      );
      await flushBloc();
      emittedStates.clear();

      bloc.add(BlogChangeReceived(right(BlogInserted(blog))));
      await flushBloc();

      expect(
        emittedStates.last,
        isA<BlogsSuccess>()
            .having(
              (state) => state.blogs.map((blog) => blog.id).toList(),
              'blog ids',
              ['blog-1', 'blog-2'],
            )
            .having(
              (state) => state.totalBlogsInDatabase,
              'totalBlogsInDatabase',
              2,
            ),
      );
    },
  );

  test(
    'given a blog update event when handled then it replaces the blog',
    () async {
      final controller = StreamController<Either<Failure, BlogsPageSnapshot>>();
      addTearDown(controller.close);

      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(1));
      when(() => watchBlogsPage(1)).thenAnswer((_) => controller.stream);

      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await flushBloc();
      controller.add(
        right(
          BlogsPageSnapshot(
            pageNumber: 1,
            blogs: [blog],
            source: BlogsPageSource.remote,
          ),
        ),
      );
      await flushBloc();
      emittedStates.clear();

      bloc.add(BlogChangeReceived(right(BlogUpdated(updatedBlog))));
      await flushBloc();

      expect(
        emittedStates.last,
        isA<BlogsSuccess>().having(
          (state) => state.blogs.single.title,
          'updated title',
          'Updated title',
        ),
      );
    },
  );

  test(
    'given a blog delete event when handled then it removes the deleted blog',
    () async {
      final controller = StreamController<Either<Failure, BlogsPageSnapshot>>();
      addTearDown(controller.close);

      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(2));
      when(() => watchBlogsPage(1)).thenAnswer((_) => controller.stream);

      final bloc = BlogsBloc(
        watchBlogsPage: watchBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      await flushBloc();
      controller.add(
        right(
          BlogsPageSnapshot(
            pageNumber: 1,
            blogs: [blog, blog2],
            source: BlogsPageSource.remote,
          ),
        ),
      );
      await flushBloc();
      emittedStates.clear();

      bloc.add(BlogChangeReceived(right(BlogDeleted(blog.id))));
      await flushBloc();

      expect(
        emittedStates.last,
        isA<BlogsSuccess>()
            .having(
              (state) => state.blogs.map((blog) => blog.id).toList(),
              'blog ids',
              ['blog-2'],
            )
            .having(
              (state) => state.totalBlogsInDatabase,
              'totalBlogsInDatabase',
              1,
            ),
      );
    },
  );
}
