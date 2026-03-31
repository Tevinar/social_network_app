import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/chat/data/data_sources/chat_message_remote_data_source.dart';
import 'package:social_app/features/chat/data/models/chat_message_model.dart';
import 'package:social_app/features/chat/data/repositories/chat_message_repository_impl.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';

class MockChatMessageRemoteDataSource extends Mock
    implements ChatMessageRemoteDataSource {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockChatMessageRemoteDataSource remote;
  late MockAppLogger logger;
  late ChatMessageRepositoryImpl repository;

  final messageModel = ChatMessageModel(
    id: 'message-1',
    chatId: 'chat-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  setUp(() async {
    await GetIt.I.reset();
    remote = MockChatMessageRemoteDataSource();
    logger = MockAppLogger();
    GetIt.I.registerSingleton<AppLogger>(logger);
    repository = ChatMessageRepositoryImpl(chatMessageRemoteDataSource: remote);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('getChatMessagesPage', () {
    test(
      'given remote succeeds when getChatMessagesPage is invoked then '
      'returns Right<List<ChatMessage>>',
      () async {
        // Arrange
        when(
          () => remote.getChatMessagesPage(2, 'chat-1'),
        ).thenAnswer((_) async => [messageModel]);

        // Act
        final result = await repository.getChatMessagesPage(2, 'chat-1');

        // Assert
        expect(result, isA<Right<Failure, dynamic>>());
        result.fold(
          (_) => fail('Expected success'),
          (messages) {
            expect(messages, hasLength(1));
            expect(messages.first.id, messageModel.id);
          },
        );
      },
    );

    test(
      'given an unexpected exception when getChatMessagesPage is invoked '
      'then returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getChatMessagesPage(2, 'chat-1'),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getChatMessagesPage(2, 'chat-1');

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in ChatMessageRepositoryImpl.getChatMessagesPage',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('getChatMessagesCount', () {
    test(
      'given remote succeeds when getChatMessagesCount is invoked then '
      'returns Right<int>',
      () async {
        // Arrange
        when(
          () => remote.getChatMessagesCount('chat-1'),
        ).thenAnswer((_) async => 3);

        // Act
        final result = await repository.getChatMessagesCount('chat-1');

        // Assert
        expect(result, right<Failure, int>(3));
      },
    );

    test(
      'given an unexpected exception when getChatMessagesCount is invoked '
      'then returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.getChatMessagesCount('chat-1'),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.getChatMessagesCount('chat-1');

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in '
            'ChatMessageRepositoryImpl.getChatMessagesCount',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('watchChatMessageChanges', () {
    test(
      'given remote emits changes when watchChatMessageChanges is listened '
      'to then emits Right<ChatMessageChange>',
      () async {
        // Arrange
        final change = ChatMessageInserted(
          chatId: 'chat-1',
          chatMessage: messageModel.toEntity(),
        );
        when(
          () => remote.watchChatMessageChanges(),
        ).thenAnswer((_) => Stream.value(change));

        // Act
        final stream = repository.watchChatMessageChanges();

        // Assert
        await expectLater(
          stream,
          emitsInOrder([
            right<Failure, ChatMessageChange>(change),
            emitsDone,
          ]),
        );
      },
    );

    test(
      'given remote emits an unexpected stream error when '
      'watchChatMessageChanges is listened to then emits Left and logs the '
      'error',
      () async {
        // Arrange
        when(
          () => remote.watchChatMessageChanges(),
        ).thenAnswer(
          (_) => Stream<ChatMessageChange>.error(
            const ServerException(message: 'boom'),
          ),
        );

        // Act
        final stream = repository.watchChatMessageChanges();

        // Assert
        await expectLater(
          stream,
          emits(
            isA<Left<Failure, ChatMessageChange>>().having(
              (value) => value.value,
              'failure',
              isA<UnexpectedFailure>(),
            ),
          ),
        );
        verify(
          () => logger.error(
            'Unexpected error in '
            'ChatMessageRepositoryImpl.watchChatMessageChanges',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });

  group('createChatMessage', () {
    test(
      'given remote succeeds when createChatMessage is invoked then returns '
      'Right<void>',
      () async {
        // Arrange
        when(
          () => remote.postChatMessage(chatId: 'chat-1', content: 'Hello'),
        ).thenAnswer((_) async {});

        // Act
        final result = await repository.createChatMessage(
          chatId: 'chat-1',
          content: 'Hello',
        );

        // Assert
        expect(result, right<Failure, void>(null));
      },
    );

    test(
      'given an unexpected exception when createChatMessage is invoked then '
      'returns Left and logs the error',
      () async {
        // Arrange
        when(
          () => remote.postChatMessage(chatId: 'chat-1', content: 'Hello'),
        ).thenThrow(const ServerException(message: 'boom'));

        // Act
        final result = await repository.createChatMessage(
          chatId: 'chat-1',
          content: 'Hello',
        );

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        verify(
          () => logger.error(
            'Unexpected error in ChatMessageRepositoryImpl.createChatMessage',
            error: any(named: 'error'),
            stackTrace: any(named: 'stackTrace'),
          ),
        ).called(1);
      },
    );
  });
}
