import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/local_storage/app_directory_provider.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/network/http_downloader.dart';

class MockAppDirectoryProvider extends Mock implements AppDirectoryProvider {}

class MockHttpDownloader extends Mock implements HttpDownloader {}

void main() {
  late MockAppDirectoryProvider directoryProvider;
  late MockHttpDownloader httpDownloader;
  late ImageFileCacheImpl imageFileCache;
  late Directory tempDirectory;

  setUp(() {
    directoryProvider = MockAppDirectoryProvider();
    httpDownloader = MockHttpDownloader();
    tempDirectory = Directory.systemTemp.createTempSync('image-cache-test');

    when(
      () => directoryProvider.getApplicationDocumentsDirectory(),
    ).thenAnswer((_) async => tempDirectory);

    imageFileCache = ImageFileCacheImpl(
      directoryProvider: directoryProvider,
      httpDownloader: httpDownloader,
    );
  });

  tearDown(() async {
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'given a cached file already exists when getOrDownload is called then '
    'it returns the cached file without downloading',
    () async {
      final cacheDirectory = Directory('${tempDirectory.path}/image_cache')
        ..createSync(recursive: true);
      final cachedFile = File('${cacheDirectory.path}/blog-1.img')
        ..writeAsBytesSync([1, 2, 3]);

      final result = await imageFileCache.getOrDownload(
        cacheKey: 'blog-1',
        imageUrl: 'https://example.com/blog-1.png',
      );

      expect(result, isNotNull);
      expect(result!.path, cachedFile.path);
      expect(result.readAsBytesSync(), [1, 2, 3]);
      verifyNever(
        () => httpDownloader.downloadBytes(
          Uri.parse('https://example.com/blog-1.png'),
        ),
      );
    },
  );

  test(
    'given no cached file when getOrDownload succeeds then it downloads and '
    'stores the image on disk',
    () async {
      when(
        () => httpDownloader.downloadBytes(
          Uri.parse('https://example.com/blog-2.png'),
        ),
      ).thenAnswer((_) async => Uint8List.fromList([4, 5, 6]));

      final result = await imageFileCache.getOrDownload(
        cacheKey: 'blog-2',
        imageUrl: 'https://example.com/blog-2.png',
      );

      expect(result, isNotNull);
      expect(result!.existsSync(), isTrue);
      expect(result.readAsBytesSync(), [4, 5, 6]);
      verify(
        () => httpDownloader.downloadBytes(
          Uri.parse('https://example.com/blog-2.png'),
        ),
      ).called(1);
    },
  );

  test(
    'given no cached file when download fails then getOrDownload returns null',
    () async {
      when(
        () => httpDownloader.downloadBytes(
          Uri.parse('https://example.com/blog-3.png'),
        ),
      ).thenThrow(const HttpException('download failed'));

      final result = await imageFileCache.getOrDownload(
        cacheKey: 'blog-3',
        imageUrl: 'https://example.com/blog-3.png',
      );

      expect(result, isNull);
      final expectedFile = File('${tempDirectory.path}/image_cache/blog-3.img');
      expect(expectedFile.existsSync(), isFalse);
      verify(
        () => httpDownloader.downloadBytes(
          Uri.parse('https://example.com/blog-3.png'),
        ),
      ).called(1);
    },
  );
}
