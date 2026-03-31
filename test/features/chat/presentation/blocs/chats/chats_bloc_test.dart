import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_chats_count.dart';
import 'package:social_app/features/chat/domain/usecases/get_chats_page.dart';
import 'package:social_app/features/chat/presentation/blocs/chats/chats_bloc.dart';

class MockGetChatsPage extends Mock implements GetChatsPage {}

class MockGetChatsCount extends Mock implements GetChatsCount {}

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockGetChatsPage getChatsPage;
  late MockGetChatsCount getChatsCount;
  late MockChatRepository repository;
  late StreamController<Either<Failure, ChatChange>> chatChangeController;

  const user1 = User(id: 'user-1', name: 'Alice', email: 'alice@test.com');
  const user2 = User(id: 'user-2', name: 'Bob', email: 'bob@test.com');

  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );
  final updatedMessage = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Updated',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025, 1, 2),
  );
  final chat = Chat(
    id: 'chat-1',
    lastMessage: message,
    members: const [user1, user2],
  );
  final updatedChat = Chat(
    id: 'chat-1',
    lastMessage: updatedMessage,
    members: const [user1, user2],
  );
  final chat2 = Chat(
    id: 'chat-2',
    lastMessage: message,
    members: const [user1],
  );

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    getChatsPage = MockGetChatsPage();
    getChatsCount = MockGetChatsCount();
    repository = MockChatRepository();
    chatChangeController = StreamController<Either<Failure, ChatChange>>();

    when(() => repository.watchChatChanges()).thenAnswer(
      (_) => chatChangeController.stream,
    );
  });

  tearDown(() async {
    await chatChangeController.close();
  });

  test(
    'given the bloc is created when reading state then state is ChatsLoading',
    () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getChatsPage(any())).thenAnswer((_) async => const Right([]));

      final bloc = ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
      addTearDown(bloc.close);

      expect(bloc.state, isA<ChatsLoading>());
    },
  );

  blocTest<ChatsBloc, ChatsState>(
    'given the initial load succeeds when the bloc is created then it emits '
    'loading states and success',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(1));
      when(() => getChatsPage(1)).thenAnswer((_) async => Right([chat]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    expect: () => [
      isA<ChatsLoading>(),
      isA<ChatsLoading>(),
      isA<ChatsSuccess>()
          .having((state) => state.chats, 'chats', [chat])
          .having((state) => state.pageNumber, 'pageNumber', 2),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given getChatsCount fails when the initial load runs then it emits '
    'failure before continuing',
    build: () {
      when(
        () => getChatsCount(any()),
      ).thenAnswer((_) async => left(const NetworkFailure()));
      when(() => getChatsPage(1)).thenAnswer((_) async => Right([chat]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    expect: () => [
      isA<ChatsFailure>().having(
        (state) => state.error,
        'error',
        'No internet connection.',
      ),
      isA<ChatsLoading>(),
      isA<ChatsSuccess>(),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given getChatsPage fails when loading a page then it emits ChatsFailure',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(2));
      when(
        () => getChatsPage(1),
      ).thenAnswer((_) async => left(const ValidationFailure('boom')));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    expect: () => [
      isA<ChatsLoading>(),
      isA<ChatsLoading>(),
      isA<ChatsFailure>().having((state) => state.error, 'error', 'boom'),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given all chats are already loaded when LoadChatsNextPage is added '
    'then it emits nothing',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(1));
      when(() => getChatsPage(1)).thenAnswer((_) async => Right([chat]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    seed: () => ChatsSuccess(
      chats: [chat],
      pageNumber: 2,
      totalChatsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(LoadChatsNextPage()),
    expect: () => <ChatsState>[],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given chats are already loading when LoadChatsNextPage is added then '
    'it emits nothing',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(2));
      when(() => getChatsPage(1)).thenAnswer((_) async => Right([chat]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    seed: () => ChatsLoading(
      chats: [chat],
      pageNumber: 2,
      totalChatsInDatabase: 2,
    ),
    act: (bloc) => bloc.add(LoadChatsNextPage()),
    expect: () => <ChatsState>[],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given ChatChangeReceived with a failure when handled then it emits '
    'ChatsFailure',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getChatsPage(any())).thenAnswer((_) async => const Right([]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    seed: () => ChatsSuccess(
      chats: [chat],
      pageNumber: 2,
      totalChatsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(
      ChatChangeReceived(left(const ValidationFailure('stream boom'))),
    ),
    expect: () => [
      isA<ChatsFailure>().having(
        (state) => state.error,
        'error',
        'stream boom',
      ),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given ChatInserted when handled then it prepends the inserted chat',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getChatsPage(any())).thenAnswer((_) async => const Right([]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    seed: () => ChatsSuccess(
      chats: [chat2],
      pageNumber: 2,
      totalChatsInDatabase: 1,
    ),
    act: (bloc) => bloc.add(ChatChangeReceived(right(ChatInserted(chat)))),
    expect: () => [
      isA<ChatsSuccess>()
          .having((state) => state.chats, 'chats', [chat, chat2])
          .having((state) => state.totalChatsInDatabase, 'count', 2),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given ChatUpdated when handled then it replaces the existing chat',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getChatsPage(any())).thenAnswer((_) async => const Right([]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    seed: () => ChatsSuccess(
      chats: [chat],
      pageNumber: 2,
      totalChatsInDatabase: 1,
    ),
    act: (bloc) =>
        bloc.add(ChatChangeReceived(right(ChatUpdated(updatedChat)))),
    expect: () => [
      isA<ChatsSuccess>().having(
        (state) => state.chats.single.lastMessage.content,
        'updated content',
        'Updated',
      ),
    ],
  );

  blocTest<ChatsBloc, ChatsState>(
    'given ChatDeleted when handled then it removes the deleted chat',
    build: () {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getChatsPage(any())).thenAnswer((_) async => const Right([]));
      return ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
    },
    seed: () => ChatsSuccess(
      chats: [chat, chat2],
      pageNumber: 2,
      totalChatsInDatabase: 2,
    ),
    act: (bloc) => bloc.add(ChatChangeReceived(right(ChatDeleted(chat.id)))),
    expect: () => [
      isA<ChatsSuccess>()
          .having((state) => state.chats, 'chats', [chat2])
          .having((state) => state.totalChatsInDatabase, 'count', 1),
    ],
  );

  test(
    'given the repository stream emits a chat change when the bloc listens '
    'then it converts it into state updates',
    () async {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(0));
      when(() => getChatsPage(any())).thenAnswer((_) async => const Right([]));

      final bloc = ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
      addTearDown(bloc.close);

      final emittedStates = <ChatsState>[];
      final subscription = bloc.stream.listen(emittedStates.add);
      addTearDown(subscription.cancel);

      chatChangeController.add(right(ChatInserted(chat)));
      await Future<void>.delayed(Duration.zero);

      expect(
        emittedStates.any(
          (state) => state.chats.isNotEmpty && state.chats.first.id == chat.id,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'given the scroll controller is near the bottom when the list scrolls '
    'then it loads the next page',
    (tester) async {
      when(() => getChatsCount(any())).thenAnswer((_) async => const Right(3));
      when(() => getChatsPage(1)).thenAnswer((_) async => Right([chat]));
      when(() => getChatsPage(2)).thenAnswer((_) async => Right([chat2]));

      final bloc = ChatsBloc(
        getChatsPage: getChatsPage,
        getChatsCount: getChatsCount,
        repository: repository,
      );
      addTearDown(bloc.close);

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

      verify(() => getChatsPage(2)).called(1);
    },
  );
}
