import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/domain/usecases/watch_blog_by_id.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_viewer/blog_viewer_bloc.dart';
import 'package:social_app/features/blog/presentation/pages/blog_viewer_page.dart';

class MockWatchBlogById extends Mock implements WatchBlogById {}

class MockImageFileCache extends Mock implements ImageFileCache {}

void main() {
  late MockWatchBlogById watchBlogById;
  late MockImageFileCache imageFileCache;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: List.filled(220, 'word').join(' '),
    imageUrl: 'https://image.test/blog.png',
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUp(() async {
    await GetIt.I.reset();
    watchBlogById = MockWatchBlogById();
    imageFileCache = MockImageFileCache();
    when(() => watchBlogById(any())).thenAnswer(
      (_) => Stream.value(
        right(
          BlogSnapshot(
            blog: blog,
            source: BlogSource.remote,
          ),
        ),
      ),
    );
    when(
      () => imageFileCache.getOrDownload(
        cacheKey: any(named: 'cacheKey'),
        imageUrl: any(named: 'imageUrl'),
      ),
    ).thenAnswer((_) async => null);
    serviceLocator
      ..registerFactory<BlogViewerBloc>(
        () => BlogViewerBloc(watchBlogById: watchBlogById),
      )
      ..registerLazySingleton<ImageFileCache>(() => imageFileCache);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Widget buildTestableWidget({required Widget child}) {
    return MaterialApp(home: child);
  }

  testWidgets(
    'given a blog is fetched when BlogViewerPage is rendered then it shows '
    'a loader during image precache before the content',
    (tester) async {
      final imageCompleter = Completer<File?>();
      when(
        () => imageFileCache.getOrDownload(
          cacheKey: blog.id,
          imageUrl: blog.imageUrl,
        ),
      ).thenAnswer((_) => imageCompleter.future);

      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(blogId: blog.id),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(Loader), findsOneWidget);

      imageCompleter.complete(null);
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('By Alice'), findsOneWidget);
      expect(find.text(blog.content), findsOneWidget);
    },
  );

  testWidgets(
    'given the fetch is pending when BlogViewerPage is rendered then it '
    'fetches the blog by id and then shows the content',
    (tester) async {
      final controller = StreamController<Either<Failure, BlogSnapshot>>();
      addTearDown(controller.close);

      when(() => watchBlogById(blog.id)).thenAnswer((_) => controller.stream);

      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(blogId: blog.id),
        ),
      );

      await tester.pump();
      expect(find.byType(Loader), findsOneWidget);
      expect(find.text('Title'), findsNothing);

      controller.add(
        right(
          BlogSnapshot(
            blog: blog,
            source: BlogSource.remote,
          ),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => watchBlogById(blog.id)).called(1);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('By Alice'), findsOneWidget);
    },
  );

  testWidgets(
    'given the blog fetch fails when BlogViewerPage is rendered then it '
    'shows the failure message',
    (tester) async {
      when(() => watchBlogById(blog.id)).thenAnswer(
        (_) => Stream.value(left(const ValidationFailure('Blog fetch failed'))),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: const BlogViewerPage(
            blogId: 'blog-1',
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.text('Blog fetch failed'), findsOneWidget);
    },
  );

  testWidgets(
    'given cached data and a refresh failure when BlogViewerPage is rendered '
    'then it keeps showing the blog content',
    (tester) async {
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
              refreshFailure: const ValidationFailure('Refresh failed'),
            ),
          ),
        ]),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(blogId: blog.id),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('By Alice'), findsOneWidget);
      expect(find.text(blog.content), findsOneWidget);
    },
  );

  testWidgets(
    'given image resolution is pending when BlogViewerPage is rendered then '
    'it shows a loader while the image future resolves',
    (tester) async {
      final imageCompleter = Completer<File?>();
      when(
        () => imageFileCache.getOrDownload(
          cacheKey: blog.id,
          imageUrl: blog.imageUrl,
        ),
      ).thenAnswer((_) => imageCompleter.future);

      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(blogId: blog.id),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(Loader), findsOneWidget);

      imageCompleter.complete(null);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'given a previous route when the back button is tapped then '
    'BlogViewerPage pops',
    (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlogViewerPage(
                        blogId: blog.id,
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      expect(find.byType(BlogViewerPage), findsNothing);
    },
  );
}
