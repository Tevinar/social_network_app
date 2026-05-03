import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_local_data_source.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blog_snapshot.dart';
import 'package:social_app/features/blog/domain/value_objects/blog_topic.dart';
import 'package:social_app/features/blog/domain/entities/blogs_page_snapshot.dart';

class MockBlogRemoteDataSource extends Mock implements BlogRemoteDataSource {}

class MockBlogLocalDataSource extends Mock implements BlogLocalDataSource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockBlogRemoteDataSource remote;
  late MockBlogLocalDataSource local;
  late MockAppLogger logger;
  late BlogRepositoryImpl repository;

  final blogModel = BlogModel(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const [BlogTopic.technology],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUp(() async {
    await GetIt.I.reset();
    remote = MockBlogRemoteDataSource();
    local = MockBlogLocalDataSource();
    logger = MockAppLogger();
    GetIt.I.registerSingleton<AppLogger>(logger);
    repository = BlogRepositoryImpl(
      blogRemoteDataSource: remote,
      blogLocalDataSource: local,
    );
    when(() => local.upsertBlogs(any())).thenAnswer((_) async {});
    when(
      () => local.getBlogsPage(any()),
    ).thenAnswer((_) async => <BlogModel>[]);
    when(() => local.getBlogById(any())).thenAnswer((_) async => null);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  setUpAll(() {
    registerFallbackValue(File('/tmp/image.png'));
    registerFallbackValue(
      BlogModel(
        id: '',
        posterId: '',
        title: '',
        content: '',
        imageUrl: '',
        topics: const [],
        updatedAt: DateTime(2025),
        posterName: '',
      ),
    );
  });

  group('createBlog', () {
    test(
      'given remote calls succeed when createBlog is invoked then caches and '
      'returns the created blog',
      () async {
        when(
          () => remote.uploadBlogImage(
            image: any(named: 'image'),
            blogId: any(named: 'blogId'),
          ),
        ).thenAnswer((_) async => 'https://image');
        when(() => remote.postBlog(any())).thenAnswer((_) async => blogModel);

        final result = await repository.createBlog(
          image: File('/tmp/image.png'),
          title: 'Title',
          content: 'Content',
          posterId: 'user-1',
          posterName: 'Alice',
          topics: const [BlogTopic.technology],
        );

        expect(result, isA<Right<Failure, dynamic>>());
        final capturedBlogs =
            verify(() => local.upsertBlogs(captureAny())).captured.single
                as List<BlogModel>;
        expect(capturedBlogs.single.id, blogModel.id);
      },
    );

    test(
      'given a known exception when createBlog is invoked then returns '
      'Left<Failure>',
      () async {
        when(
          () => remote.uploadBlogImage(
            image: any(named: 'image'),
            blogId: any(named: 'blogId'),
          ),
        ).thenThrow(const NetworkException(message: 'offline'));

        final result = await repository.createBlog(
          image: File('/tmp/image.png'),
          title: 'Title',
          content: 'Content',
          posterId: 'user-1',
          posterName: 'Alice',
          topics: const [BlogTopic.technology],
        );

        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected a failure'),
        );
      },
    );
  });

  group('watchBlogsPage', () {
    test(
      'given cache and remote succeed when watchBlogsPage is listened to then '
      'it emits cache then remote',
      () async {
        when(() => local.getBlogsPage(2)).thenAnswer((_) async => [blogModel]);
        when(() => remote.getBlogsPage(2)).thenAnswer((_) async => [blogModel]);

        final stream = repository.watchBlogsPage(2);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Right<Failure, BlogsPageSnapshot>>()
                .having(
                  (value) => value.value.source,
                  'source',
                  BlogsPageSource.cache,
                )
                .having(
                  (value) => value.value.blogs.single.id,
                  'blog id',
                  'blog-1',
                ),
            isA<Right<Failure, BlogsPageSnapshot>>()
                .having(
                  (value) => value.value.source,
                  'source',
                  BlogsPageSource.remote,
                )
                .having(
                  (value) => value.value.blogs.single.id,
                  'blog id',
                  'blog-1',
                ),
            emitsDone,
          ]),
        );
        final capturedBlogs =
            verify(() => local.upsertBlogs(captureAny())).captured.single
                as List<BlogModel>;
        expect(capturedBlogs.single.id, blogModel.id);
      },
    );

    test(
      'given remote fails without cache when watchBlogsPage is listened to '
      'then it emits Left<Failure>',
      () async {
        when(
          () => remote.getBlogsPage(2),
        ).thenThrow(const NetworkException(message: 'offline'));

        final stream = repository.watchBlogsPage(2);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Left<Failure, BlogsPageSnapshot>>().having(
              (value) => value.value,
              'failure',
              isA<NetworkFailure>(),
            ),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given cache exists and remote fails when watchBlogsPage is listened to '
      'then it emits cached data with a refresh failure',
      () async {
        when(() => local.getBlogsPage(2)).thenAnswer((_) async => [blogModel]);
        when(
          () => remote.getBlogsPage(2),
        ).thenThrow(const ServerException(message: 'boom', code: '23505'));

        final stream = repository.watchBlogsPage(2);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Right<Failure, BlogsPageSnapshot>>().having(
              (value) => value.value.source,
              'source',
              BlogsPageSource.cache,
            ),
            isA<Right<Failure, BlogsPageSnapshot>>().having(
              (value) => value.value.refreshFailure,
              'refreshFailure',
              isA<ValidationFailure>(),
            ),
            emitsDone,
          ]),
        );
      },
    );
  });

  group('getBlogsCount', () {
    test(
      'given remote succeeds when getBlogsCount is invoked then returns '
      'Right<int>',
      () async {
        when(() => remote.getBlogsCount()).thenAnswer((_) async => 3);

        final result = await repository.getBlogsCount();

        expect(result, right<Failure, int>(3));
      },
    );
  });

  group('getBlogById', () {
    test(
      'given remote succeeds when getBlogById is invoked then caches and '
      'returns Right<Blog>',
      () async {
        when(
          () => remote.getBlogById(blogModel.id),
        ).thenAnswer((_) async => blogModel);

        final result = await repository.getBlogById(blogModel.id);

        expect(result, isA<Right<Failure, dynamic>>());
        final capturedBlogs =
            verify(() => local.upsertBlogs(captureAny())).captured.single
                as List<BlogModel>;
        expect(capturedBlogs.single.id, blogModel.id);
      },
    );

    test(
      'given cached data and remote failure when getBlogById is invoked then '
      'returns the cached blog',
      () async {
        when(() => local.getBlogById(blogModel.id)).thenAnswer(
          (_) async => blogModel,
        );
        when(
          () => remote.getBlogById(blogModel.id),
        ).thenThrow(const NetworkException(message: 'offline'));

        final result = await repository.getBlogById(blogModel.id);

        expect(result, isA<Right<Failure, dynamic>>());
        result.fold(
          (_) => fail('Expected success'),
          (blog) => expect(blog.id, blogModel.id),
        );
      },
    );

    test(
      'given no cached data and an unexpected remote exception when '
      'getBlogById is invoked then returns Left and logs the error',
      () async {
        when(
          () => remote.getBlogById(blogModel.id),
        ).thenThrow(const ServerException(message: 'boom'));

        final result = await repository.getBlogById(blogModel.id);

        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in BlogRepositoryImpl.getBlogById',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('watchBlogById', () {
    test(
      'given cache and remote succeed when watchBlogById is listened to then '
      'it emits cache then remote',
      () async {
        when(() => local.getBlogById(blogModel.id)).thenAnswer(
          (_) async => blogModel,
        );
        when(
          () => remote.getBlogById(blogModel.id),
        ).thenAnswer((_) async => blogModel);

        final stream = repository.watchBlogById(blogModel.id);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Right<Failure, BlogSnapshot>>()
                .having(
                  (value) => value.value.source,
                  'source',
                  BlogSource.cache,
                )
                .having(
                  (value) => value.value.blog.id,
                  'blog id',
                  blogModel.id,
                ),
            isA<Right<Failure, BlogSnapshot>>()
                .having(
                  (value) => value.value.source,
                  'source',
                  BlogSource.remote,
                )
                .having(
                  (value) => value.value.blog.id,
                  'blog id',
                  blogModel.id,
                ),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given cached data and remote failure when watchBlogById is listened to '
      'then it emits cached data with a refresh failure',
      () async {
        when(() => local.getBlogById(blogModel.id)).thenAnswer(
          (_) async => blogModel,
        );
        when(
          () => remote.getBlogById(blogModel.id),
        ).thenThrow(const NetworkException(message: 'offline'));

        final stream = repository.watchBlogById(blogModel.id);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Right<Failure, BlogSnapshot>>().having(
              (value) => value.value.source,
              'source',
              BlogSource.cache,
            ),
            isA<Right<Failure, BlogSnapshot>>().having(
              (value) => value.value.refreshFailure,
              'refreshFailure',
              isA<NetworkFailure>(),
            ),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given no cached data and remote failure when watchBlogById is listened '
      'to then it emits Left<Failure>',
      () async {
        when(
          () => remote.getBlogById(blogModel.id),
        ).thenThrow(const NetworkException(message: 'offline'));

        final stream = repository.watchBlogById(blogModel.id);

        await expectLater(
          stream,
          emitsInOrder([
            isA<Left<Failure, BlogSnapshot>>().having(
              (value) => value.value,
              'failure',
              isA<NetworkFailure>(),
            ),
            emitsDone,
          ]),
        );
      },
    );
  });

  group('watchBlogChanges', () {
    test(
      'given remote emits blog changes when watchBlogChanges is listened to '
      'then emits Right<BlogChange>',
      () async {
        final change = BlogInserted(blogModel.toEntity());
        when(
          () => remote.watchBlogChanges(),
        ).thenAnswer((_) => Stream.value(change));

        final stream = repository.watchBlogChanges();

        await expectLater(
          stream,
          emitsInOrder([
            right<Failure, BlogChange>(change),
            emitsDone,
          ]),
        );
      },
    );
  });
}
