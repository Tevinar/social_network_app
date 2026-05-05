import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/local_storage/image_file_cache.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_local_data_source.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:social_app/features/blog/domain/entities/blog.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';

class MockBlogRemoteDataSource extends Mock implements BlogRemoteDataSource {}

class MockBlogLocalDataSource extends Mock implements BlogLocalDataSource {}

class MockImageFileCache extends Mock implements ImageFileCache {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockBlogRemoteDataSource blogRemoteDataSource;
  late MockBlogLocalDataSource blogLocalDataSource;
  late MockImageFileCache imageFileCache;
  late MockAppLogger logger;
  late BlogRepositoryImpl repository;

  final blog = Blog(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Blog title',
    content: 'Blog content',
    imageUrl: 'https://example.com/blog-1.png',
    topics: [BlogTopic.technology],
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 2),
    posterName: 'Test User',
  );

  final imageFile = File('${Directory.systemTemp.path}/blog-image-test.img');

  setUp(() async {
    blogRemoteDataSource = MockBlogRemoteDataSource();
    blogLocalDataSource = MockBlogLocalDataSource();
    imageFileCache = MockImageFileCache();
    logger = MockAppLogger();

    await GetIt.I.reset();
    GetIt.I.registerSingleton<AppLogger>(logger);

    repository = BlogRepositoryImpl(
      blogRemoteDataSource: blogRemoteDataSource,
      blogLocalDataSource: blogLocalDataSource,
      imageFileCache: imageFileCache,
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('getBlogImage', () {
    test(
      'given the cache returns a file when retrieving a blog image then Right<File?> is returned',
      () async {
        when(
          () => imageFileCache.getOrDownload(
            cacheKey: blog.id,
            imageUrl: blog.imageUrl,
          ),
        ).thenAnswer((_) async => imageFile);

        final result = await repository.getBlogImage(blog);

        expect(
          result,
          isA<Right<Failure, File?>>().having(
            (value) => value.value,
            'image file',
            imageFile,
          ),
        );
      },
    );

    test(
      'given image retrieval throws a network exception when retrieving a blog image then Left<NetworkFailure> is returned',
      () async {
        when(
          () => imageFileCache.getOrDownload(
            cacheKey: blog.id,
            imageUrl: blog.imageUrl,
          ),
        ).thenThrow(const NetworkException(message: 'offline'));

        final result = await repository.getBlogImage(blog);

        expect(result, isA<Left<Failure, File?>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected failure'),
        );
      },
    );
  });
}
