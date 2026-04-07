import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_count.dart';
import 'package:social_app/features/blog/domain/usecases/get_blogs_page.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_changes.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/blogs_bloc.dart';

class MockGetBlogsPage extends Mock implements GetBlogsPage {}

class MockGetBlogsCount extends Mock implements GetBlogsCount {}

class MockWatchBlogChanges extends Mock implements WatchBlogChanges {}

void main() {
  late MockGetBlogsPage getBlogsPage;
  late MockGetBlogsCount getBlogsCount;
  late MockWatchBlogChanges watchBlogChanges;
  late StreamController<Either<Failure, BlogChange>> blogChangeController;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );
  final updatedBlog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Updated title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025, 1, 2),
    posterName: 'Alice',
  );
  final blog2 = Blog(
    id: 'blog-2',
    posterId: 'user-2',
    title: 'Second',
    content: 'More content',
    imageUrl: 'https://image-2',
    topics: const ['Science'],
    updatedAt: DateTime(2025, 1, 3),
    posterName: 'Bob',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getBlogsPage = MockGetBlogsPage();
    getBlogsCount = MockGetBlogsCount();
    watchBlogChanges = MockWatchBlogChanges();
    blogChangeController = StreamController<Either<Failure, BlogChange>>();

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
      // Arrange
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));

      // Act
      final bloc = BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      // Assert
      expect(bloc.state, isA<BlogsLoading>());
    },
  );

  blocTest<BlogsBloc, BlogsState>(
    'given the initial load succeeds when the bloc is created then it emits '
    'loading states and success',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(1));
      when(() => getBlogsPage(1)).thenAnswer((_) async => Right([blog]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    expect: () => [
      isA<BlogsLoading>().having(
        (state) => state.totalBlogsInDatabase,
        'totalBlogsInDatabase',
        1,
      ),
      isA<BlogsLoading>().having(
        (state) => state.totalBlogsInDatabase,
        'totalBlogsInDatabase',
        1,
      ),
      isA<BlogsSuccess>()
          .having((state) => state.blogs, 'blogs', [blog])
          .having((state) => state.pageNumber, 'pageNumber', 2)
          .having(
            (state) => state.totalBlogsInDatabase,
            'totalBlogsInDatabase',
            1,
          ),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given getBlogsCount fails when the initial load runs then it emits '
    'failure before continuing',
    build: () {
      when(
        () => getBlogsCount(any()),
      ).thenAnswer((_) async => left(const NetworkFailure()));
      when(() => getBlogsPage(1)).thenAnswer((_) async => Right([blog]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    expect: () => [
      isA<BlogsFailure>().having(
        (state) => state.error,
        'error',
        'No internet connection.',
      ),
      isA<BlogsLoading>(),
      isA<BlogsSuccess>().having((state) => state.blogs, 'blogs', [blog]),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given getBlogsPage fails when loading a page then it emits BlogsFailure',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(2));
      when(
        () => getBlogsPage(1),
      ).thenAnswer((_) async => left(const ValidationFailure('boom')));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    expect: () => [
      isA<BlogsLoading>(),
      isA<BlogsLoading>(),
      isA<BlogsFailure>().having((state) => state.error, 'error', 'boom'),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given all blogs are already loaded when LoadBlogsNextPage is added '
    'then it emits nothing',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(1));
      when(() => getBlogsPage(1)).thenAnswer((_) async => Right([blog]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsSuccess(
      blogs: [blog],
      pageNumber: 2,
      totalBlogsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(LoadBlogsNextPage()),
    expect: () => <BlogsState>[],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given blogs are already loading when LoadBlogsNextPage is added then '
    'it emits nothing',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(2));
      when(() => getBlogsPage(1)).thenAnswer((_) async => Right([blog]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsLoading(
      blogs: [blog],
      pageNumber: 2,
      totalBlogsInDatabase: 2,
    ),
    act: (bloc) => bloc.add(LoadBlogsNextPage()),
    expect: () => <BlogsState>[],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given BlogChangeReceived with a failure when handled then it emits '
    'BlogsFailure',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsSuccess(
      blogs: [blog],
      pageNumber: 2,
      totalBlogsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      BlogChangeReceived(left(const ValidationFailure('stream boom'))),
    ),
    expect: () => [
      isA<BlogsFailure>().having(
        (state) => state.error,
        'error',
        'stream boom',
      ),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given BlogInserted when handled then it prepends the inserted blog',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsSuccess(
      blogs: [blog2],
      pageNumber: 2,
      totalBlogsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(BlogChangeReceived(right(BlogInserted(blog)))),
    expect: () => [
      isA<BlogsSuccess>()
          .having((state) => state.blogs, 'blogs', [blog, blog2])
          .having(
            (state) => state.totalBlogsInDatabase,
            'totalBlogsInDatabase',
            2,
          ),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given BlogUpdated when handled then it replaces the existing blog',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsSuccess(
      blogs: [blog],
      pageNumber: 2,
      totalBlogsInDatabase: 1,
    ),
    act: (bloc) =>
        bloc.add(BlogChangeReceived(right(BlogUpdated(updatedBlog)))),
    expect: () => [
      isA<BlogsSuccess>().having(
        (state) => state.blogs.single.title,
        'updated title',
        'Updated title',
      ),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given BlogDeleted when handled then it removes the deleted blog',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsSuccess(
      blogs: [blog, blog2],
      pageNumber: 2,
      totalBlogsInDatabase: 2,
    ),
    act: (bloc) => bloc.add(BlogChangeReceived(right(BlogDeleted(blog.id)))),
    expect: () => [
      isA<BlogsSuccess>()
          .having((state) => state.blogs, 'blogs', [blog2])
          .having(
            (state) => state.totalBlogsInDatabase,
            'totalBlogsInDatabase',
            1,
          ),
    ],
  );

  blocTest<BlogsBloc, BlogsState>(
    'given RefreshBlogsView when handled then it re-emits the current state '
    'values',
    build: () {
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));
      return BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
    },
    seed: () => BlogsSuccess(
      blogs: [blog],
      pageNumber: 2,
      totalBlogsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(RefreshBlogsView()),
    expect: () => [
      isA<BlogsSuccess>()
          .having((state) => state.blogs, 'blogs', [blog])
          .having((state) => state.pageNumber, 'pageNumber', 2),
    ],
  );

  test(
    'given the repository stream emits a blog change when the bloc listens '
    'then it converts it into state updates',
    () async {
      // Arrange
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));
      final bloc = BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      final emittedStates = <BlogsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      // Act
      blogChangeController.add(right(BlogInserted(blog)));
      await Future<void>.delayed(Duration.zero);

      // Assert
      expect(
        emittedStates.any(
          (state) => state.blogs.isNotEmpty && state.blogs.first.id == blog.id,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'given the scroll controller is near the bottom when the list scrolls '
    'then it loads the next page',
    (tester) async {
      // Arrange
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(3));
      when(() => getBlogsPage(1)).thenAnswer((_) async => Right([blog]));
      when(() => getBlogsPage(2)).thenAnswer((_) async => Right([blog2]));

      final bloc = BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: bloc.scrollController,
            itemCount: 30,
            itemBuilder: (context, index) => const SizedBox(height: 100),
          ),
        ),
      );
      await tester.pump();

      // Act
      bloc.scrollController.jumpTo(
        bloc.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      // Assert
      verify(() => getBlogsPage(2)).called(1);
    },
  );

  testWidgets(
    'given the list is scrolled down when scrollToTop is called then it '
    'animates back to offset zero',
    (tester) async {
      // Arrange
      when(() => getBlogsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getBlogsPage(any())).thenAnswer((_) async => const Right([]));

      final bloc = BlogsBloc(
        getBlogsPage: getBlogsPage,
        getBlogsCount: getBlogsCount,
        watchBlogChanges: watchBlogChanges,
      );
      addTearDown(bloc.close);

      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: bloc.scrollController,
            itemCount: 30,
            itemBuilder: (context, index) => const SizedBox(height: 100),
          ),
        ),
      );
      await tester.pump();
      bloc.scrollController.jumpTo(300);
      await tester.pump();

      // Act
      final scrollToTopFuture = bloc.scrollToTop();
      await tester.pump();
      await tester.pumpAndSettle();
      await scrollToTopFuture;

      // Assert
      expect(bloc.scrollController.offset, 0);
    },
  );
}
