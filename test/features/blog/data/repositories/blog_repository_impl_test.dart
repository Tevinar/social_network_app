import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';

class MockBlogRemoteDataSource extends Mock implements BlogRemoteDataSource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockBlogRemoteDataSource remote;
  late MockAppLogger logger;
  late BlogRepositoryImpl repository;

  final blogModel = BlogModel(
    id: 'blog-1',
    posterId: 'user-1',
    title: 'Title',
    content: 'Content',
    imageUrl: 'https://image',
    topics: const ['Tech'],
    updatedAt: DateTime(2025),
    posterName: 'Alice',
  );

  setUp(() async {
    await GetIt.I.reset();
    remote = MockBlogRemoteDataSource();
    logger = MockAppLogger();
    GetIt.I.registerSingleton<AppLogger>(logger);
    repository = BlogRepositoryImpl(blogRemoteDataSource: remote);
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
      ),
    );
  });

  group('createBlog', () {
    test(
      'given remote calls succeed when createBlog is invoked then returns '
      'Right<Blog>',
      () async {
        // Arrange
        when(
          () => remote.uploadBlogImage(
            image: any(named: 'image'),
            blogId: any(named: 'blogId'),
          ),
        ).thenAnswer((_) async => 'https://image');
        when(() => remote.postBlog(any())).thenAnswer((_) async => blogModel);

        // Act
        final result = await repository.createBlog(
          image: File('/tmp/image.png'),
          title: 'Title',
          content: 'Content',
          posterId: 'user-1',
          topics: const ['Tech'],
        );

        // Assert
        expect(result, isA<Right<Failure, dynamic>>());
        result.fold(
          (_) => fail('Expected success'),
          (blog) {
            expect(blog.id, blogModel.id);
            expect(blog.title, blogModel.title);
          },
        );
        verify(
          () => remote.uploadBlogImage(
            image: any(named: 'image'),
            blogId: any(named: 'blogId'),
          ),
        ).called(1);
        verify(() => remote.postBlog(any(that: isA<BlogModel>()))).called(1);
      },
    );

    test(
      'given a known exception when createBlog is invoked then returns '
      'Left<Failure>',
      () async {
        // Arrange
        when(
          () => remote.uploadBlogImage(
            image: any(named: 'image'),
            blogId: any(named: 'blogId'),
          ),
        ).thenThrow(const NetworkException(message: 'offline'));

        // Act
        final result = await repository.createBlog(
          image: File('/tmp/image.png'),
          title: 'Title',
          content: 'Content',
          posterId: 'user-1',
          topics: const ['Tech'],
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Expected a failure'),
        );
      },
    );

    test(
      'given an unexpected exception when createBlog is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.uploadBlogImage(
            image: any(named: 'image'),
            blogId: any(named: 'blogId'),
          ),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.createBlog(
          image: File('/tmp/image.png'),
          title: 'Title',
          content: 'Content',
          posterId: 'user-1',
          topics: const ['Tech'],
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in BlogRepositoryImpl.createBlog',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('getBlogsPage', () {
    test(
      'given remote succeeds when getBlogsPage is invoked then returns '
      'Right<List<Blog>>',
      () async {
        // Arrange
        when(() => remote.getBlogsPage(2)).thenAnswer((_) async => [blogModel]);

        // Act
        final result = await repository.getBlogsPage(2);

        // Assert
        expect(
          result,
          isA<Right<Failure, List<dynamic>>>(),
        );
        result.fold(
          (_) => fail('Expected success'),
          (blogs) {
            expect(blogs, hasLength(1));
            expect(blogs.first.id, blogModel.id);
            expect(blogs.first.posterId, blogModel.posterId);
            expect(blogs.first.title, blogModel.title);
          },
        );
      },
    );

    test(
      'given an unexpected exception when getBlogsPage is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getBlogsPage(2),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getBlogsPage(2);

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in BlogRepositoryImpl.getBlogsPage',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('getBlogsCount', () {
    test(
      'given remote succeeds when getBlogsCount is invoked then returns '
      'Right<int>',
      () async {
        // Arrange
        when(() => remote.getBlogsCount()).thenAnswer((_) async => 3);

        // Act
        final result = await repository.getBlogsCount();

        // Assert
        expect(result, right<Failure, int>(3));
      },
    );

    test(
      'given an unexpected exception when getBlogsCount is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getBlogsCount(),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getBlogsCount();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in BlogRepositoryImpl.getBlogsCount',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('watchBlogChanges', () {
    test(
      'given remote emits blog changes when watchBlogChanges is listened to '
      'then emits Right<BlogChange>',
      () async {
        // Arrange
        final change = BlogInserted(blogModel.toEntity());
        when(
          () => remote.watchBlogChanges(),
        ).thenAnswer((_) => Stream.value(change));

        // Act
        final stream = repository.watchBlogChanges();

        // Assert
        await expectLater(
          stream,
          emitsInOrder([
            right<Failure, BlogChange>(change),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given remote emits an unexpected stream error when watchBlogChanges '
      'is listened to then emits Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.watchBlogChanges(),
        ).thenAnswer(
          (_) =>
              Stream<BlogChange>.error(const ServerException(message: 'boom')),
        );

        // Act
        final stream = repository.watchBlogChanges();

        // Assert
        await expectLater(
          stream,
          emits(
            isA<Left<Failure, BlogChange>>().having(
              (value) => value.value,
              'failure',
              isA<UnexpectedFailure>(),
            ),
          ),
        );
        verify(
          () => logger.error(
            'Unexpected error in BlogRepositoryImpl.watchBlogChanges',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });
}
