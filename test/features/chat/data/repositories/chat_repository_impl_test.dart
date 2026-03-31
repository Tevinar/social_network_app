import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/data/models/user_model.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/data/models/chat_model.dart';
import 'package:social_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockChatRemoteDataSource remote;
  late MockAppLogger logger;
  late ChatRepositoryImpl repository;

  const user = User(id: 'user-1', name: 'Alice', email: 'alice@test.com');
  const userModel = UserModel(
    id: 'user-1',
    name: 'Alice',
    email: 'alice@test.com',
  );
  final chatModel = ChatModel(
    id: 'chat-1',
    lastMessage: ChatMessageModel(
      id: 'message-1',
      chatId: 'chat-1',
      authorId: 'user-1',
      content: 'Hello',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    members: const [userModel],
  );

  setUp(() async {
    await GetIt.I.reset();
    remote = MockChatRemoteDataSource();
    logger = MockAppLogger();
    GetIt.I.registerSingleton<AppLogger>(logger);
    repository = ChatRepositoryImpl(chatRemoteDataSource: remote);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('createChat', () {
    test(
      'given remote succeeds when createChat is invoked then returns '
      'Right<Chat>',
      () async {
        // Arrange
        when(
          () => remote.createChat(any(), any()),
        ).thenAnswer((_) async => chatModel);

        // Act
        final result = await repository.createChat(const [user], 'Hello');

        // Assert
        expect(result, isA<Right<Failure, dynamic>>());
        result.fold(
          (_) => fail('Expected success'),
          (chat) => expect(chat.id, chatModel.id),
        );
      },
    );

    test(
      'given an unexpected exception when createChat is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.createChat(any(), any()),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.createChat(const [user], 'Hello');

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in ChatRepositoryImpl.createChat',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('getChatsPage', () {
    test(
      'given remote succeeds when getChatsPage is invoked then returns '
      'Right<List<Chat>>',
      () async {
        // Arrange
        when(() => remote.getChatsPage(2)).thenAnswer((_) async => [chatModel]);

        // Act
        final result = await repository.getChatsPage(2);

        // Assert
        expect(result, isA<Right<Failure, dynamic>>());
        result.fold(
          (_) => fail('Expected success'),
          (chats) {
            expect(chats, hasLength(1));
            expect(chats.first.id, chatModel.id);
          },
        );
      },
    );

    test(
      'given an unexpected exception when getChatsPage is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getChatsPage(2),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getChatsPage(2);

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in ChatRepositoryImpl.getChatsPage',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('getChatsCount', () {
    test(
      'given remote succeeds when getChatsCount is invoked then returns '
      'Right<int>',
      () async {
        // Arrange
        when(() => remote.getChatsCount()).thenAnswer((_) async => 3);

        // Act
        final result = await repository.getChatsCount();

        // Assert
        expect(result, right<Failure, int>(3));
      },
    );

    test(
      'given an unexpected exception when getChatsCount is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getChatsCount(),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getChatsCount();

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in ChatRepositoryImpl.getChatsCount',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('watchChatChanges', () {
    test(
      'given remote emits changes when watchChatChanges is listened to then '
      'emits Right<ChatChange>',
      () async {
        // Arrange
        final change = ChatInserted(chatModel.toEntity());
        when(
          () => remote.watchChatChanges(),
        ).thenAnswer((_) => Stream.value(change));

        // Act
        final stream = repository.watchChatChanges();

        // Assert
        await expectLater(
          stream,
          emitsInOrder([
            right<Failure, ChatChange>(change),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given remote emits an unexpected stream error when watchChatChanges '
      'is listened to then emits Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.watchChatChanges(),
        ).thenAnswer(
          (_) =>
              Stream<ChatChange>.error(const ServerException(message: 'boom')),
        );

        // Act
        final stream = repository.watchChatChanges();

        // Assert
        await expectLater(
          stream,
          emits(
            isA<Left<Failure, ChatChange>>().having(
              (value) => value.value,
              'failure',
              isA<UnexpectedFailure>(),
            ),
          ),
        );
        verify(
          () => logger.error(
            'Unexpected error in ChatRepositoryImpl.watchChatChanges',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('getChatByMembers', () {
    test(
      'given remote succeeds when getChatByMembers is invoked then returns '
      'Right<Chat?>',
      () async {
        // Arrange
        when(
          () => remote.getChatByMembers(any()),
        ).thenAnswer((_) async => chatModel);

        // Act
        final result = await repository.getChatByMembers(const [user]);

        // Assert
        expect(result, isA<Right<Failure, dynamic>>());
        result.fold(
          (_) => fail('Expected success'),
          (chat) => expect(chat?.id, chatModel.id),
        );
      },
    );

    test(
      'given remote returns null when getChatByMembers is invoked then '
      'returns Right(null)',
      () async {
        // Arrange
        when(
          () => remote.getChatByMembers(any()),
        ).thenAnswer((_) async => null);

        // Act
        final result = await repository.getChatByMembers(const [user]);

        // Assert
        expect(result, const Right<Failure, dynamic>(null));
      },
    );

    test(
      'given an unexpected exception when getChatByMembers is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getChatByMembers(any()),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getChatByMembers(const [user]);

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in ChatRepositoryImpl.getChatByMembers',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });
}
