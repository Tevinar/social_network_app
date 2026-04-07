import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/usecases/get_blog_by_id.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_viewer/bloc/blog_viewer_bloc.dart';
import 'package:social_app/features/blog/presentation/pages/blog_viewer_page.dart';

class _TestImageProvider extends ImageProvider<_TestImageProvider> {
  const _TestImageProvider();

  @override
  Future<_TestImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _TestImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_loadImageInfo());
  }

  Future<ImageInfo> _loadImageInfo() async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      Uint8List.fromList([255, 255, 255, 255]),
      1,
      1,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    final image = await completer.future;
    return ImageInfo(image: image);
  }
}

class MockGetBlogById extends Mock implements GetBlogById {}

void main() {
  late MockGetBlogById getBlogById;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: List.filled(220, 'word').join(' '),
    imageUrl: 'https://image.test/blog.png',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUp(() async {
    await GetIt.I.reset();
    getBlogById = MockGetBlogById();
    when(() => getBlogById(any())).thenAnswer((_) async => right(blog));
    serviceLocator.registerFactory<BlogViewerBloc>(
      () => BlogViewerBloc(getBlogById: getBlogById),
    );
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
      final precacheCompleter = Completer<void>();

      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(
            blogId: blog.id,
            imageProvider: const _TestImageProvider(),
            precacheImageCallback: (context, imageProvider) =>
                precacheCompleter.future,
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(Loader), findsOneWidget);

      precacheCompleter.complete();
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
      final request = Completer<Either<Failure, Blog>>();

      when(() => getBlogById(blog.id)).thenAnswer((_) => request.future);

      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(
            blogId: blog.id,
            imageProvider: const _TestImageProvider(),
            precacheImageCallback: (context, imageProvider) async {},
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(Loader), findsNothing);
      expect(find.text('Title'), findsNothing);

      request.complete(right(blog));
      await tester.pumpAndSettle();

      verify(() => getBlogById(blog.id)).called(1);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('By Alice'), findsOneWidget);
    },
  );

  testWidgets(
    'given the blog fetch fails when BlogViewerPage is rendered then it '
    'shows the failure message',
    (tester) async {
      when(() => getBlogById(blog.id)).thenAnswer(
        (_) async => left(const ValidationFailure('Blog fetch failed')),
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
    'given no precache callback when BlogViewerPage is rendered then it '
    'shows a loader while the default precacheImage future resolves',
    (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: BlogViewerPage(
            blogId: blog.id,
            imageProvider: const _TestImageProvider(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byType(Loader), findsOneWidget);
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
                        imageProvider: const _TestImageProvider(),
                        precacheImageCallback:
                            (context, imageProvider) async {},
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
