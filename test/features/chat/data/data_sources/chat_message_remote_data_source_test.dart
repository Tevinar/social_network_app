import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/chat/data/data_sources/chat_message_remote_data_source.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient supabaseClient;
  late ChatMessageRemoteDataSourceImpl dataSource;
  late FakeSupabaseQueryBuilder queryBuilder;
  late FakeListBuilder listBuilder;
  late FakeInsertBuilder insertBuilder;
  late FakeIntBuilder countBuilder;
  late FakeRealtimeChannel realtimeChannel;
  late FakeRealtimeClient realtimeClient;

  final rawMessage = <String, dynamic>{
    ChatMessageFields.id: 'message-1',
    ChatMessageFields.chatId: 'chat-1',
    ChatMessageFields.authorId: 'user-1',
    ChatMessageFields.content: 'Hello',
    ChatMessageFields.createdAt: DateTime(2025).toIso8601String(),
    ChatMessageFields.updatedAt: DateTime(2025).toIso8601String(),
  };

  setUp(() {
    supabaseClient = MockSupabaseClient();
    listBuilder = FakeListBuilder(
      result: [rawMessage],
      countResponse: const PostgrestResponse(data: [], count: 3),
    );
    insertBuilder = FakeInsertBuilder(listBuilder);
    countBuilder = FakeIntBuilder(0);
    queryBuilder = FakeSupabaseQueryBuilder(
      selectBuilder: listBuilder,
      insertBuilder: insertBuilder,
      countBuilder: countBuilder,
    );
    realtimeChannel = FakeRealtimeChannel();
    realtimeClient = FakeRealtimeClient(realtimeChannel);

    dataSource = ChatMessageRemoteDataSourceImpl(
      supabaseClient: supabaseClient,
    );

    when(
      () => supabaseClient.from(Tables.chatMessages),
    ).thenAnswer((_) => queryBuilder);
    when(() => supabaseClient.realtime).thenReturn(realtimeClient);
  });

  group('getChatMessagesPage', () {
    test(
      'given a page number and chat id when getChatMessagesPage is called '
      'then returns a mapped page of messages',
      () async {
        // Act
        final result = await dataSource.getChatMessagesPage(2, 'chat-1');

        // Assert
        expect(listBuilder.eqColumn, ChatMessageFields.chatId);
        expect(listBuilder.eqValue, 'chat-1');
        expect(listBuilder.rangeFrom, 20);
        expect(listBuilder.rangeTo, 39);
        expect(listBuilder.orderColumn, ChatMessageFields.createdAt);
        expect(result.single.id, 'message-1');
      },
    );
  });

  group('getChatMessagesCount', () {
    test(
      'given a chat id when getChatMessagesCount is called then returns the '
      'remote count',
      () async {
        // Act
        final result = await dataSource.getChatMessagesCount('chat-1');

        // Assert
        expect(result, 3);
      },
    );
  });

  group('postChatMessage', () {
    test(
      'given a chat id and content when postChatMessage is called then '
      'inserts the message',
      () async {
        // Act
        await dataSource.postChatMessage(chatId: 'chat-1', content: 'Hello');

        // Assert
        expect(insertBuilder.insertedValues, <String, dynamic>{
          ChatMessageFields.chatId: 'chat-1',
          ChatMessageFields.content: 'Hello',
        });
      },
    );

    test(
      'given a network error when postChatMessage is called then throws '
      'NetworkException',
      () async {
        // Arrange
        when(
          () => supabaseClient.from(Tables.chatMessages),
        ).thenThrow(const SocketException('offline'));

        // Act
        final result = dataSource.postChatMessage(
          chatId: 'chat-1',
          content: 'Hello',
        );

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('watchChatMessageChanges', () {
    test(
      'given an insert payload when watchChatMessageChanges is listened to '
      'then emits ChatMessageInserted',
      () async {
        // Arrange
        final stream = dataSource.watchChatMessageChanges();
        final emitted = <ChatMessageChange>[];
        final subscription = stream.listen(emitted.add);

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chatMessages,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.insert,
            newRecord: rawMessage,
            oldRecord: const {},
            errors: null,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(
          realtimeClient.topic,
          '${SchemaTypes.public}:${Tables.chatMessages}',
        );
        expect(emitted.single, isA<ChatMessageInserted>());

        await subscription.cancel();
        expect(realtimeChannel.unsubscribed, isTrue);
      },
    );

    test(
      'given an update payload when watchChatMessageChanges is listened to '
      'then emits ChatMessageUpdated',
      () async {
        // Arrange
        final stream = dataSource.watchChatMessageChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emits(isA<ChatMessageUpdated>()),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chatMessages,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.update,
            newRecord: rawMessage,
            oldRecord: const {},
            errors: null,
          ),
        );
        await expectation;
      },
    );

    test(
      'given a delete payload when watchChatMessageChanges is listened to '
      'then emits ChatMessageDeleted',
      () async {
        // Arrange
        final stream = dataSource.watchChatMessageChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emits(
            isA<ChatMessageDeleted>()
                .having((change) => change.chatId, 'chatId', 'chat-1')
                .having(
                  (change) => change.chatMessageId,
                  'chatMessageId',
                  'message-1',
                ),
          ),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chatMessages,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.delete,
            newRecord: const {},
            oldRecord: const {
              ChatMessageFields.chatId: 'chat-1',
              ChatMessageFields.id: 'message-1',
            },
            errors: null,
          ),
        );
        await expectation;
      },
    );

    test(
      'given an all payload when watchChatMessageChanges is listened to '
      'then it emits nothing',
      () async {
        // Arrange
        final stream = dataSource.watchChatMessageChanges();
        final emitted = <ChatMessageChange>[];
        final subscription = stream.listen(emitted.add);

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chatMessages,
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
      'given an invalid realtime payload when watchChatMessageChanges is '
      'listened to then emits a ServerException error',
      () async {
        // Arrange
        final stream = dataSource.watchChatMessageChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emitsError(isA<ServerException>()),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chatMessages,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.insert,
            newRecord: const {
              ChatMessageFields.id: 'message-1',
              ChatMessageFields.chatId: 'chat-1',
              ChatMessageFields.authorId: 'user-1',
              ChatMessageFields.content: 'Hello',
              ChatMessageFields.createdAt: 'invalid',
              ChatMessageFields.updatedAt: '2025-01-01T00:00:00.000',
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
