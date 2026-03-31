import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/constants/supabase_schema/fields/chat_fields.dart';
import 'package:social_app/core/constants/supabase_schema/fields/chat_message_fields.dart';
import 'package:social_app/core/constants/supabase_schema/schema_names.dart';
import 'package:social_app/core/constants/supabase_schema/tables.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/supabase_fakes.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient supabaseClient;
  late ChatRemoteDataSourceImpl dataSource;
  late FakeSupabaseQueryBuilder queryBuilder;
  late FakeListBuilder listBuilder;
  late FakeInsertBuilder insertBuilder;
  late FakeIntBuilder countBuilder;
  late FakeRealtimeChannel realtimeChannel;
  late FakeRealtimeClient realtimeClient;

  const member = UserModel(id: 'user-1', name: 'Alice', email: '');

  final rawChatMessage = <String, dynamic>{
    ChatMessageFields.id: 'message-1',
    ChatMessageFields.chatId: 'chat-1',
    ChatMessageFields.authorId: 'user-1',
    ChatMessageFields.content: 'Hello',
    ChatMessageFields.createdAt: DateTime(2025).toIso8601String(),
    ChatMessageFields.updatedAt: DateTime(2025).toIso8601String(),
  };

  final rawChat = <String, dynamic>{
    ChatFields.id: 'chat-1',
    Tables.chatMembers: [
      {
        Tables.profiles: <String, dynamic>{'id': 'user-1', 'name': 'Alice'},
      },
    ],
    Tables.chatMessages: rawChatMessage,
  };

  setUp(() {
    supabaseClient = MockSupabaseClient();
    listBuilder = FakeListBuilder(result: [rawChat], singleResult: rawChat);
    insertBuilder = FakeInsertBuilder(listBuilder);
    countBuilder = FakeIntBuilder(4);
    queryBuilder = FakeSupabaseQueryBuilder(
      selectBuilder: listBuilder,
      insertBuilder: insertBuilder,
      countBuilder: countBuilder,
    );
    realtimeChannel = FakeRealtimeChannel();
    realtimeClient = FakeRealtimeClient(realtimeChannel);

    dataSource = ChatRemoteDataSourceImpl(supabaseClient: supabaseClient);

    when(
      () => supabaseClient.from(Tables.chats),
    ).thenAnswer((_) => queryBuilder);
    when(() => supabaseClient.realtime).thenReturn(realtimeClient);
  });

  group('createChat', () {
    test(
      'given members and a first message when createChat is called then '
      'returns a ChatModel',
      () async {
        // Arrange
        when(
          () => supabaseClient.rpc<Map<String, dynamic>>(
            'create_chat_with_members',
            params: {
              'member_ids': ['user-1'],
              'first_message_content': 'Hello',
            },
          ),
        ).thenAnswer(
          (_) => FakeValueBuilder<Map<String, dynamic>>(rawChatMessage),
        );

        // Act
        final result = await dataSource.createChat(const [member], 'Hello');

        // Assert
        expect(result.id, 'chat-1');
        expect(result.lastMessage.id, 'message-1');
        expect(result.members, const [member]);
      },
    );

    test(
      'given a network error when createChat is called then throws '
      'NetworkException',
      () async {
        // Arrange
        when(
          () => supabaseClient.rpc<Map<String, dynamic>>(
            any(),
            params: any(named: 'params'),
          ),
        ).thenThrow(const SocketException('offline'));

        // Act
        final result = dataSource.createChat(const [member], 'Hello');

        // Assert
        await expectLater(result, throwsA(isA<NetworkException>()));
      },
    );
  });

  group('getChatsPage', () {
    test(
      'given a page number when getChatsPage is called then returns a '
      'mapped page of chats',
      () async {
        // Act
        final result = await dataSource.getChatsPage(2);

        // Assert
        expect(listBuilder.rangeFrom, 20);
        expect(listBuilder.rangeTo, 39);
        expect(listBuilder.orderColumn, ChatFields.lastMessageAt);
        expect(listBuilder.orderAscending, isFalse);
        expect(result.single.id, 'chat-1');
        expect(result.single.members.single.name, 'Alice');
      },
    );
  });

  group('getChatsCount', () {
    test(
      'given getChatsCount is called then returns the remote count',
      () async {
        // Act
        final result = await dataSource.getChatsCount();

        // Assert
        expect(result, 4);
      },
    );
  });

  group('getChatById', () {
    test(
      'given a chat id when getChatById is called then returns the '
      'requested chat',
      () async {
        // Act
        final result = await dataSource.getChatById('chat-1');

        // Assert
        expect(listBuilder.eqColumn, ChatFields.id);
        expect(listBuilder.eqValue, 'chat-1');
        expect(result.id, 'chat-1');
      },
    );
  });

  group('getChatByMembers', () {
    test(
      'given matching members when getChatByMembers is called then returns '
      'the matching chat',
      () async {
        // Arrange
        when(
          () => supabaseClient.rpc<Map<String, dynamic>?>(
            'get_chat_by_members',
            params: {
              'member_ids': ['user-1'],
            },
          ),
        ).thenAnswer(
          (_) => FakeValueBuilder<Map<String, dynamic>?>(rawChat),
        );

        // Act
        final result = await dataSource.getChatByMembers(const [member]);

        // Assert
        expect(result?.id, 'chat-1');
      },
    );

    test(
      'given no matching members when getChatByMembers is called then '
      'returns null',
      () async {
        // Arrange
        when(
          () => supabaseClient.rpc<Map<String, dynamic>?>(
            'get_chat_by_members',
            params: {
              'member_ids': ['user-1'],
            },
          ),
        ).thenAnswer((_) => FakeValueBuilder<Map<String, dynamic>?>(null));

        // Act
        final result = await dataSource.getChatByMembers(const [member]);

        // Assert
        expect(result, isNull);
      },
    );
  });

  group('watchChatChanges', () {
    test(
      'given an insert payload when watchChatChanges is listened to then '
      'emits ChatInserted',
      () async {
        // Arrange
        final stream = dataSource.watchChatChanges();
        final emitted = <ChatChange>[];
        final subscription = stream.listen(emitted.add);

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chats,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.insert,
            newRecord: const {ChatFields.id: 'chat-1'},
            oldRecord: const {},
            errors: null,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(realtimeClient.topic, '${SchemaTypes.public}:${Tables.chats}');
        expect(realtimeChannel.subscribed, isTrue);
        expect(emitted.single, isA<ChatInserted>());

        await subscription.cancel();
        expect(realtimeChannel.unsubscribed, isTrue);
      },
    );

    test(
      'given an update payload when watchChatChanges is listened to then '
      'emits ChatUpdated',
      () async {
        // Arrange
        final stream = dataSource.watchChatChanges();

        // Assert
        final expectation = expectLater(stream, emits(isA<ChatUpdated>()));

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chats,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.update,
            newRecord: const {ChatFields.id: 'chat-1'},
            oldRecord: const {},
            errors: null,
          ),
        );
        await expectation;
      },
    );

    test(
      'given a delete payload when watchChatChanges is listened to then '
      'emits ChatDeleted',
      () async {
        // Arrange
        final stream = dataSource.watchChatChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emits(
            isA<ChatDeleted>().having(
              (change) => change.chatId,
              'chatId',
              'chat-1',
            ),
          ),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chats,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.delete,
            newRecord: const {},
            oldRecord: const {ChatFields.id: 'chat-1'},
            errors: null,
          ),
        );
        await expectation;
      },
    );

    test(
      'given an all payload when watchChatChanges is listened to then it '
      'emits nothing',
      () async {
        // Arrange
        final stream = dataSource.watchChatChanges();
        final emitted = <ChatChange>[];
        final subscription = stream.listen(emitted.add);

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chats,
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
      'given an invalid realtime payload when watchChatChanges is listened '
      'to then emits a ServerException error',
      () async {
        // Arrange
        listBuilder = FakeListBuilder(
          result: const [<String, dynamic>{}],
          singleResult: const <String, dynamic>{},
        );
        queryBuilder = FakeSupabaseQueryBuilder(
          selectBuilder: listBuilder,
          insertBuilder: FakeInsertBuilder(listBuilder),
          countBuilder: countBuilder,
        );
        when(
          () => supabaseClient.from(Tables.chats),
        ).thenAnswer((_) => queryBuilder);
        final stream = dataSource.watchChatChanges();

        // Assert
        final expectation = expectLater(
          stream,
          emitsError(isA<ServerException>()),
        );

        // Act
        realtimeChannel.emit(
          PostgresChangePayload(
            schema: SchemaTypes.public,
            table: Tables.chats,
            commitTimestamp: DateTime(2025),
            eventType: PostgresChangeEvent.insert,
            newRecord: const {ChatFields.id: 'chat-1'},
            oldRecord: const {},
            errors: null,
          ),
        );
        await expectation;
      },
    );
  });
}
