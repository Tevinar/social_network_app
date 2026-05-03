import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_cases/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:social_app/features/chat/domain/usecases/create_chat_message.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_messages_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_messages_page.dart';
import 'package:social_app/features/chat/domain/usecases/watch_chat_message_changes.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_messages/chat_messages_bloc.dart';

class MockGetChatMessagesPage extends Mock implements GetChatMessagesPage {}

class MockGetChatMessagesCount extends Mock implements GetChatMessagesCount {}

class MockWatchChatMessageChanges extends Mock
    implements WatchChatMessageChanges {}

class MockCreateChatMessage extends Mock implements CreateChatMessage {}

void main() {
  late MockGetChatMessagesPage getChatMessagesPage;
  late MockGetChatMessagesCount getChatMessagesCount;
  late MockWatchChatMessageChanges watchChatMessageChanges;
  late MockCreateChatMessage createChatMessage;
  late StreamController<Either<Failure, ChatMessageChange>>
  chatMessageChangeController;

  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025, 1, 1, 10),
    updatedAt: DateTime(2025, 1, 1, 10),
  );
  final updatedMessage = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Updated',
    createdAt: DateTime(2025, 1, 1, 10),
    updatedAt: DateTime(2025, 1, 1, 11),
  );
  final message2 = ChatMessage(
    id: 'message-2',
    authorId: 'user-2',
    content: 'Hi',
    createdAt: DateTime(2025, 1, 1, 9),
    updatedAt: DateTime(2025, 1, 1, 9),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      GetChatMessagesPageParams(pageNumber: 1, chatId: 'chat-1'),
    );
    registerFallbackValue(
      CreateChatMessageParams(chatId: 'chat-1', content: 'Hello'),
    );
  });

  setUp(() {
    getChatMessagesPage = MockGetChatMessagesPage();
    getChatMessagesCount = MockGetChatMessagesCount();
    watchChatMessageChanges = MockWatchChatMessageChanges();
    createChatMessage = MockCreateChatMessage();
    chatMessageChangeController =
        StreamController<Either<Failure, ChatMessageChange>>();

    when(() => watchChatMessageChanges(any())).thenAnswer(
      (_) => chatMessageChangeController.stream,
    );
  });

  tearDown(() async {
    await chatMessageChangeController.close();
  });

  test(
    'given the bloc is created when reading state then state is '
    'ChatMessagesLoading',
    () {
      final bloc = ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
      addTearDown(bloc.close);

      expect(bloc.state, isA<ChatMessagesLoading>());
      expect(bloc.state.chatId, '');
    },
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given the initial page load succeeds when LoadInitialChatMessagesPage '
    'is added then it emits loading states and success',
    build: () {
      when(() => getChatMessagesCount('chat-1')).thenAnswer(
        (_) async => const Right(2),
      );
      when(() => getChatMessagesPage(any())).thenAnswer(
        (_) async => Right([message, message2]),
      );
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    act: (bloc) => bloc.add(LoadInitialChatMessagesPage('chat-1')),
    expect: () => [
      isA<ChatMessagesLoading>().having(
        (state) => state.chatId,
        'chatId',
        'chat-1',
      ),
      isA<ChatMessagesLoading>().having(
        (state) => state.totalChatMessagesInDatabase,
        'totalChatMessagesInDatabase',
        2,
      ),
      isA<ChatMessagesLoading>().having(
        (state) => state.chatId,
        'chatId',
        'chat-1',
      ),
      isA<ChatMessagesSuccess>()
          .having((state) => state.chatMessages, 'chatMessages', [
            message,
            message2,
          ])
          .having((state) => state.pageNumber, 'pageNumber', 2),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given getChatMessagesCount fails when loading a page then it emits '
    'failure before continuing',
    build: () {
      when(() => getChatMessagesCount('chat-1')).thenAnswer(
        (_) async => left(const ValidationFailure('count failed')),
      );
      when(
        () => getChatMessagesPage(any()),
      ).thenAnswer((_) async => Right([message]));
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    act: (bloc) => bloc.add(LoadInitialChatMessagesPage('chat-1')),
    expect: () => [
      isA<ChatMessagesLoading>().having(
        (state) => state.chatId,
        'chatId',
        'chat-1',
      ),
      isA<ChatMessagesFailure>().having(
        (state) => state.error,
        'error',
        'count failed',
      ),
      isA<ChatMessagesLoading>(),
      isA<ChatMessagesSuccess>(),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given getChatMessagesPage fails when loading a page then it emits '
    'ChatMessagesFailure',
    build: () {
      when(() => getChatMessagesCount('chat-1')).thenAnswer(
        (_) async => const Right(2),
      );
      when(
        () => getChatMessagesPage(any()),
      ).thenAnswer((_) async => left(const ValidationFailure('page failed')));
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    act: (bloc) => bloc.add(LoadInitialChatMessagesPage('chat-1')),
    expect: () => [
      isA<ChatMessagesLoading>(),
      isA<ChatMessagesLoading>(),
      isA<ChatMessagesLoading>(),
      isA<ChatMessagesFailure>().having(
        (state) => state.error,
        'error',
        'page failed',
      ),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given createChatMessage fails when AddChatMessage is added then it '
    'emits ChatMessagesFailure',
    build: () {
      when(() => createChatMessage(any())).thenAnswer(
        (_) async => left(const ValidationFailure('Invalid message')),
      );
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(AddChatMessage('chat-1', 'Hello')),
    expect: () => [
      isA<ChatMessagesFailure>().having(
        (state) => state.error,
        'error',
        'Invalid message',
      ),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given createChatMessage succeeds when AddChatMessage is added then it '
    'emits nothing',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(AddChatMessage('chat-1', 'Hello')),
    expect: () => <ChatMessagesState>[],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given a realtime failure when ChatMessageChangeReceived is handled '
    'then it emits ChatMessagesFailure',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      ChatMessageChangeReceived(left(const ValidationFailure('stream boom'))),
    ),
    expect: () => [
      isA<ChatMessagesFailure>().having(
        (state) => state.error,
        'error',
        'stream boom',
      ),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given a realtime change for another chat when handled then it emits '
    'nothing',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      ChatMessageChangeReceived(
        right(ChatMessageInserted(chatId: 'chat-2', chatMessage: message2)),
      ),
    ),
    expect: () => <ChatMessagesState>[],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given ChatMessageInserted when handled then it prepends the inserted '
    'message',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message2],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      ChatMessageChangeReceived(
        right(ChatMessageInserted(chatId: 'chat-1', chatMessage: message)),
      ),
    ),
    expect: () => [
      isA<ChatMessagesSuccess>()
          .having((state) => state.chatMessages, 'chatMessages', [
            message,
            message2,
          ])
          .having((state) => state.totalChatMessagesInDatabase, 'count', 2),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given a duplicate ChatMessageInserted when handled then it keeps the '
    'existing collection unchanged',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      ChatMessageChangeReceived(
        right(ChatMessageInserted(chatId: 'chat-1', chatMessage: message)),
      ),
    ),
    expect: () => [
      isA<ChatMessagesSuccess>()
          .having((state) => state.chatMessages, 'chatMessages', [message])
          .having((state) => state.totalChatMessagesInDatabase, 'count', 1),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given ChatMessageUpdated when handled then it replaces the existing '
    'message',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      ChatMessageChangeReceived(
        right(
          ChatMessageUpdated(chatId: 'chat-1', chatMessage: updatedMessage),
        ),
      ),
    ),
    expect: () => [
      isA<ChatMessagesSuccess>().having(
        (state) => state.chatMessages.single.content,
        'updated content',
        'Updated',
      ),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given ChatMessageDeleted when handled then it removes the deleted message',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message, message2],
      pageNumber: 2,
      totalChatMessagesInDatabase: 2,
    ),
    act: (bloc) => bloc.add(
      ChatMessageChangeReceived(
        right(ChatMessageDeleted(chatId: 'chat-1', chatMessageId: message.id)),
      ),
    ),
    expect: () => [
      isA<ChatMessagesSuccess>()
          .having((state) => state.chatMessages, 'chatMessages', [message2])
          .having((state) => state.totalChatMessagesInDatabase, 'count', 1),
    ],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given all chat messages are already loaded when '
    'LoadChatMessagesNextPage is added then it emits nothing',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesSuccess(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 1,
    ),
    act: (bloc) => bloc.add(LoadChatMessagesNextPage()),
    expect: () => <ChatMessagesState>[],
  );

  blocTest<ChatMessagesBloc, ChatMessagesState>(
    'given chat messages are already loading when LoadChatMessagesNextPage '
    'is added then it emits nothing',
    build: () {
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
    },
    seed: () => ChatMessagesLoading(
      chatId: 'chat-1',
      chatMessages: [message],
      pageNumber: 2,
      totalChatMessagesInDatabase: 2,
    ),
    act: (bloc) => bloc.add(LoadChatMessagesNextPage()),
    expect: () => <ChatMessagesState>[],
  );

  test(
    'given the repository stream emits a message change when the bloc '
    'listens then it converts it into state updates',
    () async {
      when(() => getChatMessagesCount('chat-1')).thenAnswer(
        (_) async => const Right(0),
      );
      when(() => getChatMessagesPage(any())).thenAnswer(
        (_) async => const Right([]),
      );
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));

      final bloc = ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
      addTearDown(bloc.close);
      bloc.add(LoadInitialChatMessagesPage('chat-1'));

      final emittedStates = <ChatMessagesState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      chatMessageChangeController.add(
        right(ChatMessageInserted(chatId: 'chat-1', chatMessage: message)),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        emittedStates.any(
          (state) =>
              state.chatMessages.isNotEmpty &&
              state.chatMessages.first.id == message.id,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'given the scroll controller is near the bottom when the list scrolls '
    'then it loads the next page',
    (tester) async {
      when(() => getChatMessagesCount('chat-1')).thenAnswer(
        (_) async => const Right(3),
      );
      when(() => getChatMessagesPage(any())).thenAnswer((invocation) async {
        final params =
            invocation.positionalArguments.single as GetChatMessagesPageParams;
        if (params.pageNumber == 1) {
          return Right([message]);
        }
        return Right([message2]);
      });
      when(
        () => createChatMessage(any()),
      ).thenAnswer((_) async => const Right(null));

      final bloc = ChatMessagesBloc(
        getChatMessagesPage: getChatMessagesPage,
        getChatMessagesCount: getChatMessagesCount,
        watchChatMessageChanges: watchChatMessageChanges,
        createChatMessage: createChatMessage,
      );
      addTearDown(bloc.close);
      bloc.add(LoadInitialChatMessagesPage('chat-1'));

      await tester.pumpWidget(
        MaterialApp(
          home: ListView.builder(
            controller: bloc.scrollController,
            itemCount: 30,
            itemBuilder: (context, index) => const SizedBox(height: 100),
          ),
        ),
      );
      await tester.pump();

      bloc.scrollController.jumpTo(
        bloc.scrollController.position.maxScrollExtent,
      );
      await tester.pump();

      verify(
        () => getChatMessagesPage(
          any(
            that: isA<GetChatMessagesPageParams>().having(
              (params) => params.pageNumber,
              'pageNumber',
              2,
            ),
          ),
        ),
      ).called(1);
    },
  );
}
