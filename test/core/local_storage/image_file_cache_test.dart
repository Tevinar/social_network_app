import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/core/network/dio_http_downloader.dart';

class MockDioHttpDownloader extends Mock implements DioHttpDownloader {}

class MockAppLogger extends Mock implements AppLogger {}

class FakePathProviderPlatform extends PathProviderPlatform {
  FakePathProviderPlatform(this.applicationDocumentsPath);

  final String applicationDocumentsPath;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return applicationDocumentsPath;
  }
}

void main() {
  late MockDioHttpDownloader dioHttpDownloader;
  late MockAppLogger logger;
  late ImageFileCacheImpl imageFileCache;
  late Directory tempDir;
  late PathProviderPlatform originalPathProviderPlatform;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('image-file-cache-test-');
    originalPathProviderPlatform = PathProviderPlatform.instance;
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    dioHttpDownloader = MockDioHttpDownloader();
    logger = MockAppLogger();
    imageFileCache = ImageFileCacheImpl(dioHttpDownloader: dioHttpDownloader);

    await GetIt.I.reset();
    GetIt.I.registerSingleton<AppLogger>(logger);

    when(
      () => logger.error(
        any(),
        error: any(named: 'error'),
        stackTrace: any(named: 'stackTrace'),
      ),
    ).thenReturn(null);
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalPathProviderPlatform;
    await GetIt.I.reset();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('getOrDownload', () {
    test(
      'given a cached file when requested then returns it without downloading',
      () async {
        // Arrange
        final cacheDir = Directory('${tempDir.path}/image_cache');
        await cacheDir.create(recursive: true);
        final cachedFile = File('${cacheDir.path}/avatar.img');
        await cachedFile.writeAsBytes(const [1, 2, 3], flush: true);

        // Act
        final result = await imageFileCache.getOrDownload(
          cacheKey: 'avatar',
          imageUrl: 'https://example.com/avatar.png',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.path, cachedFile.path);
        expect(
          await result.readAsBytes(),
          Uint8List.fromList(const [1, 2, 3]),
        );
        verifyNever(() => dioHttpDownloader.downloadBytes(any()));
      },
    );

    test(
      'given no cached file when requested then downloads and stores it',
      () async {
        // Arrange
        when(() => dioHttpDownloader.downloadBytes(any())).thenAnswer(
          (_) async => Uint8List.fromList(const [9, 8, 7]),
        );

        // Act
        final result = await imageFileCache.getOrDownload(
          cacheKey: 'avatar',
          imageUrl: 'https://example.com/avatar.png',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.existsSync(), isTrue);
        expect(
          await result.readAsBytes(),
          Uint8List.fromList(const [9, 8, 7]),
        );
        verify(
          () => dioHttpDownloader.downloadBytes(
            any(
              that: predicate<Uri>(
                (value) => value.toString() == 'https://example.com/avatar.png',
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'given the download fails when requested then returns null and logs '
      'the error',
      () async {
        // Arrange
        final error = Exception('download failed');
        when(() => dioHttpDownloader.downloadBytes(any())).thenThrow(error);

        // Act
        final result = await imageFileCache.getOrDownload(
          cacheKey: 'avatar',
          imageUrl: 'https://example.com/avatar.png',
        );

        // Assert
        expect(result, isNull);
        verify(
          () => logger.error(
            'Failed to download or cache image for avatar from https://example.com/avatar.png',
            error: error,
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });
}
