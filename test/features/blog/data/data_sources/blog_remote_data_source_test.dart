import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/constants/supabase_schema/buckets.dart';
import 'package:social_app/core/constants/supabase_schema/fields/blog_fields.dart';
import 'package:social_app/core/constants/supabase_schema/fields/profile_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/blog/data/data_sources/blog_remote_data_source.dart';
import 'package:social_app/features/blog/data/models/blog_model.dart';
import 'package:social_app/features/blog/domain/entities/blog_change.dart';
import 'package:social_app/features/blog/domain/entities/blog_topic.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient supabaseClient;
  late BlogRemoteDataSourceImpl dataSource;
  late FakeSupabaseQueryBuilder queryBuilder;
  late FakeListBuilder listBuilder;
  late FakeInsertBuilder insertBuilder;
  late FakeIntBuilder countBuilder;
  late FakeSupabaseStorageClient storageClient;
  late FakeStorageFileApi storageFileApi;
  late FakeRealtimeChannel realtimeChannel;
  late FakeRealtimeClient realtimeClient;

  final rawBlog = <String, dynamic>{
    BlogFields.id: 'blog-1',
    BlogFields.posterId: 'user-1',
    BlogFields.title: 'Title',
    BlogFields.content: 'Content',
    BlogFields.imageUrl: 'https://image',
    BlogFields.topics: ['Technology'],
    BlogFields.updatedAt: DateTime(2025).toIso8601String(),
    Tables.profiles: <String, dynamic>{ProfileFields.name: 'Alice'},
  };

  setUp(() {
    supabaseClient = MockSupabaseClient();
    listBuilder = FakeListBuilder(
      result: [rawBlog],
      singleResult: rawBlog,
    );
    insertBuilder = FakeInsertBuilder(listBuilder);
    countBuilder = FakeIntBuilder(3);
    queryBuilder = FakeSupabaseQueryBuilder(
      selectBuilder: listBuilder,
      insertBuilder: insertBuilder,
      countBuilder: countBuilder,
    );
    storageFileApi = FakeStorageFileApi();
    storageClient = FakeSupabaseStorageClient()..fileApi = storageFileApi;
    realtimeChannel = FakeRealtimeChannel();
    realtimeClient = FakeRealtimeClient(realtimeChannel);

    dataSource = BlogRemoteDataSourceImpl(supabaseClient: supabaseClient);

    when(
      () => supabaseClient.from(Tables.blogs),
    ).thenAnswer((_) => queryBuilder);
    when(() => supabaseClient.storage).thenReturn(storageClient);
    when(() => supabaseClient.realtime).thenReturn(realtimeClient);
  });

  group('postBlog', () {
    test(
      'given a blog model when postBlog is called then inserts and returns '
      'the saved model',
      () async {
        // Arrange
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

        // Act
        final result = await dataSource.postBlog(blogModel);

        // Assert
        expect(insertBuilder.insertedValues, blogModel.toSupabaseInsertJson());
        expect(result.id, 'blog-1');
        expect(result.title, 'Title');
        expect(result.content, 'Content');
      },
    );

    test(
      'given a network error when postBlog is called then throws '
      'NetworkException',
      () async {
        // Arrange
        when(
          () => supabaseClient.from(Tables.blogs),
        ).thenThrow(const SocketException('offline'));

        // Act
        final result = dataSource.postBlog(
          BlogModel(
            id: 'blog-1',
            posterId: 'user-1',
            title: 'Title',
            content: 'Content',
            imageUrl: 'https://image',
            topics: const [BlogTopic.technology],
            updatedAt: DateTime(2025),
            posterName: 'Alice',
          ),
        );

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('uploadBlogImage', () {
    test(
      'given an image when uploadBlogImage is called then uploads and '
      'returns the public url',
      () async {
        // Arrange
        final image = File('/tmp/image.png');
        storageFileApi.publicUrlResult = 'https://image/public';

        // Act
        final result = await dataSource.uploadBlogImage(
          image: image,
          blogId: 'blog-1',
        );

        // Assert
        expect(storageClient.bucketId, Buckets.blogImages);
        expect(storageFileApi.uploadPath, 'blog-1');
        expect(storageFileApi.uploadedFile, image);
        expect(storageFileApi.publicUrlPath, 'blog-1');
        expect(result, 'https://image/public');
      },
    );

    test(
      'given a backend error when uploadBlogImage is called then throws '
      'ServerException',
      () async {
        // Arrange
        when(() => supabaseClient.storage).thenThrow(Exception('boom'));

        // Act
        final result = dataSource.uploadBlogImage(
          image: File('/tmp/image.png'),
          blogId: 'blog-1',
        );

        // Assert
        await expectLater(result, throwsA(isA<ServerException>()));
      },
    );
  });

  group('getBlogsPage', () {
    test(
      'given a page number when getBlogsPage is called then returns a '
      'mapped page of blogs',
      () async {
        // Act
        final result = await dataSource.getBlogsPage(2);

        // Assert
        expect(
          queryBuilder.selectedColumns,
          '*, ${Tables.profiles} (${ProfileFields.name})',
        );
        expect(listBuilder.rangeFrom, 20);
        expect(listBuilder.rangeTo, 39);
        expect(listBuilder.orderColumn, BlogFields.updatedAt);
        expect(listBuilder.orderAscending, isFalse);
        expect(result, hasLength(1));
        expect(result.first.id, 'blog-1');
        expect(result.first.posterName, 'Alice');
      },
    );
  });

  group('getBlogsCount', () {
    test(
      'given getBlogsCount is called then returns the remote count',
      () async {
        // Act
        final result = await dataSource.getBlogsCount();

        // Assert
        expect(result, 3);
      },
    );
  });

  group('getBlogById', () {
    test(
      'given a blog id when getBlogById is called then it filters by id and '
      'returns the mapped blog',
      () async {
        // Act
        final result = await dataSource.getBlogById('blog-1');

        // Assert
        expect(
          queryBuilder.selectedColumns,
          '*, ${Tables.profiles} (${ProfileFields.name})',
        );
        expect(listBuilder.eqColumn, BlogFields.id);
        expect(listBuilder.eqValue, 'blog-1');
        expect(result.id, 'blog-1');
        expect(result.title, 'Title');
        expect(result.posterName, 'Alice');
      },
    );

    test(
      'given a network error when getBlogById is called then throws '
      'NetworkException',
      () async {
        // Arrange
        when(
          () => supabaseClient.from(Tables.blogs),
        ).thenThrow(const SocketException('offline'));

        // Act
        final result = dataSource.getBlogById('blog-1');

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('watchBlogChanges', () {
    test(
      'given an insert payload when watchBlogChanges is listened to then '
      'emits BlogInserted',
      () async {
        // Arrange
        final stream = dataSource.watchBlogChanges();
        final emitted = <BlogChange>[];
        final subscription = stream.listen(emitted.add);

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.blogs,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.insert,
            newRecord: rawBlog,
            oldRecord: const {},
            errors: null,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(realtimeClient.topic, '${SchemaTypes.public}:${Tables.blogs}');
        expect(realtimeChannel.event, PostgresChangeEvent.all);
        expect(realtimeChannel.table, Tables.blogs);
        expect(realtimeChannel.subscribed, isTrue);
        expect(emitted.single, isA<BlogInserted>());

        await subscription.cancel();
        expect(realtimeChannel.unsubscribed, isTrue);
      },
    );

    test(
      'given an update payload when watchBlogChanges is listened to then '
      'emits BlogUpdated',
      () async {
        // Arrange
        final stream = dataSource.watchBlogChanges();

        // Assert
        final expectation = expectLater(stream, emits(isA<BlogUpdated>()));

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.blogs,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.update,
            newRecord: rawBlog,
            oldRecord: const {},
            errors: null,
          ),
        );
        await expectation;
      },
    );

    test(
      'given a delete payload when watchBlogChanges is listened to then '
      'emits BlogDeleted',
      () async {
        // Arrange
        final stream = dataSource.watchBlogChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emits(
            isA<BlogDeleted>().having(
              (change) => change.blogId,
              'blogId',
              'blog-1',
            ),
          ),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.blogs,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.delete,
            newRecord: const {},
            oldRecord: const {BlogFields.id: 'blog-1'},
            errors: null,
          ),
        );
        await expectation;
      },
    );

    test(
      'given an all payload when watchBlogChanges is listened to then it '
      'emits nothing',
      () async {
        // Arrange
        final stream = dataSource.watchBlogChanges();
        final emitted = <BlogChange>[];
        final subscription = stream.listen(emitted.add);

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.blogs,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.all,
            newRecord: const {},
            oldRecord: const {},
            errors: null,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(emitted, isEmpty);

        await subscription.cancel();
      },
    );

    test(
      'given an invalid realtime payload when watchBlogChanges is listened '
      'to then emits a ServerException error',
      () async {
        // Arrange
        final stream = dataSource.watchBlogChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emitsError(isA<ServerException>()),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.blogs,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.insert,
            newRecord: const {
              BlogFields.id: 'blog-1',
              BlogFields.posterId: 'user-1',
              BlogFields.title: 'Title',
              BlogFields.content: 'Content',
              BlogFields.imageUrl: 'https://image',
              BlogFields.topics: ['Technology'],
              BlogFields.updatedAt: 'invalid',
            },
            oldRecord: const {},
            errors: null,
          ),
        );
        await expectation;
      },
    );
  });
}
