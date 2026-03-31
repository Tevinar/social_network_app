import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
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

void main() {
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

  testWidgets(
    'given a blog when BlogViewerPage is rendered then it shows a loader '
    'before the content',
    (tester) async {
      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox.shrink(),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlogViewerPage(
            blog: blog,
            imageProvider: const _TestImageProvider(),
            precacheImageCallback: (context, imageProvider) async {},
          ),
        ),
      );

      // Assert
      expect(find.byType(Loader), findsOneWidget);

      // Act
      await tester.pump();

      // Assert
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('By Alice'), findsOneWidget);
      expect(find.text(blog.content), findsOneWidget);
    },
  );

  testWidgets(
    'given no precache callback when BlogViewerPage is rendered then it '
    'uses the default precacheImage future',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlogViewerPage(
            blog: blog,
            imageProvider: const _TestImageProvider(),
          ),
        ),
      );

      expect(find.byType(Loader), findsOneWidget);
    },
  );

  testWidgets(
    'given a previous route when the back button is tapped then '
    'BlogViewerPage pops',
    (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlogViewerPage(
                      blog: blog,
                      imageProvider: const _TestImageProvider(),
                      precacheImageCallback: (context, imageProvider) async {},
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(BlogViewerPage), findsNothing);
    },
  );
}
