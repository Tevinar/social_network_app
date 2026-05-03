import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/utils/format_date.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_messages/chat_messages_bloc.dart';
import 'package:social_app/features/chat/presentation/pages/chat_messages_page.dart';

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

class MockChatEditorBloc extends MockBloc<ChatEditorEvent, ChatEditorState>
    implements ChatEditorBloc {}

class MockChatMessagesBloc
    extends MockBloc<ChatMessagesEvent, ChatMessagesState>
    implements ChatMessagesBloc {}

void main() {
  late MockAppUserCubit appUserCubit;
  late MockChatEditorBloc chatEditorBloc;
  late MockChatMessagesBloc chatMessagesBloc;
  late ScrollController scrollController;
  late StreamController<ChatEditorState> chatEditorStateController;

  const currentUser = UserEntity(
    id: 'user-1',
    name: 'Alice',
    email: 'alice@test.com',
  );
  const otherUser = UserEntity(
    id: 'user-2',
    name: 'Bob',
    email: 'bob@test.com',
  );

  final message = ChatMessage(
    id: 'message-1',
    authorId: currentUser.id,
    content: 'Hello',
    createdAt: DateTime(2025, 1, 2, 10),
    updatedAt: DateTime(2025, 1, 2, 10),
  );
  final olderMessage = ChatMessage(
    id: 'message-2',
    authorId: otherUser.id,
    content: 'Hi',
    createdAt: DateTime(2025, 1, 1, 9),
    updatedAt: DateTime(2025, 1, 1, 9),
  );

  setUpAll(() {
    registerFallbackValue(LoadInitialChatMessagesPage(''));
    registerFallbackValue(AddChatMessage('', ''));
    registerFallbackValue(AddChatFirstMessage(firstMessageContent: ''));
  });

  setUp(() async {
    await GetIt.I.reset();
    appUserCubit = MockAppUserCubit();
    chatEditorBloc = MockChatEditorBloc();
    chatMessagesBloc = MockChatMessagesBloc();
    scrollController = ScrollController();
    chatEditorStateController = StreamController<ChatEditorState>.broadcast();

    serviceLocator.registerFactory<ChatMessagesBloc>(() => chatMessagesBloc);

    when(
      () => appUserCubit.state,
    ).thenReturn(const AppUserSignedIn(currentUser));
    whenListen(appUserCubit, Stream.value(const AppUserSignedIn(currentUser)));
    when(() => chatMessagesBloc.scrollController).thenReturn(scrollController);
  });

  tearDown(() async {
    await chatEditorStateController.close();
    await GetIt.I.reset();
  });

  Widget buildWidget({
    required ChatEditorState chatEditorState,
    required ChatMessagesState chatMessagesState,
  }) {
    when(() => chatEditorBloc.state).thenReturn(chatEditorState);
    whenListen(
      chatEditorBloc,
      chatEditorStateController.stream,
      initialState: chatEditorState,
    );
    when(() => chatMessagesBloc.state).thenReturn(chatMessagesState);
    whenListen(chatMessagesBloc, Stream.value(chatMessagesState));

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppUserCubit>.value(value: appUserCubit),
          BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
        ],
        child: const ChatMessagesPage(),
      ),
    );
  }

  testWidgets(
    'given a loaded chat editor when the page is built then it dispatches '
    'the initial page load and renders messages',
    (tester) async {
      const chatEditorState = ChatEditorLoaded(
        chatMembers: [currentUser, otherUser],
        chatId: 'chat-1',
      );
      final chatMessagesState = ChatMessagesSuccess(
        chatId: 'chat-1',
        chatMessages: [message, olderMessage],
        pageNumber: 2,
        totalChatMessagesInDatabase: 3,
      );

      await tester.pumpWidget(
        buildWidget(
          chatEditorState: chatEditorState,
          chatMessagesState: chatMessagesState,
        ),
      );
      await tester.pump();

      verify(
        () => chatMessagesBloc.add(
          any(
            that: isA<LoadInitialChatMessagesPage>().having(
              (event) => event.chatId,
              'chatId',
              'chat-1',
            ),
          ),
        ),
      ).called(1);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Hi'), findsOneWidget);
      expect(find.text(formatToDay(message.createdAt)), findsOneWidget);
      expect(find.text(formatToDay(olderMessage.createdAt)), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'given a loaded chat editor when a non-empty message is sent then it '
    'dispatches AddChatMessage and clears the input',
    (tester) async {
      const chatEditorState = ChatEditorLoaded(
        chatMembers: [currentUser, otherUser],
        chatId: 'chat-1',
      );

      await tester.pumpWidget(
        buildWidget(
          chatEditorState: chatEditorState,
          chatMessagesState: const ChatMessagesSuccess(
            chatId: 'chat-1',
            chatMessages: [],
            pageNumber: 1,
            totalChatMessagesInDatabase: 0,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  Hello  ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verify(
        () => chatMessagesBloc.add(
          any(
            that: isA<AddChatMessage>()
                .having((event) => event.chatId, 'chatId', 'chat-1')
                .having((event) => event.content, 'content', 'Hello'),
          ),
        ),
      ).called(1);
      expect(find.text('Hello'), findsNothing);
    },
  );

  testWidgets(
    'given an empty input when the send button is tapped then it does not '
    'dispatch any event',
    (tester) async {
      const chatEditorState = ChatEditorLoaded(
        chatMembers: [currentUser, otherUser],
        chatId: 'chat-1',
      );

      await tester.pumpWidget(
        buildWidget(
          chatEditorState: chatEditorState,
          chatMessagesState: const ChatMessagesSuccess(
            chatId: 'chat-1',
            chatMessages: [],
            pageNumber: 1,
            totalChatMessagesInDatabase: 0,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verifyNever(
        () => chatMessagesBloc.add(
          any(that: isA<AddChatMessage>()),
        ),
      );
    },
  );

  testWidgets(
    'given the first message is being drafted when a non-empty message is '
    'sent then it dispatches AddChatFirstMessage and clears the input',
    (tester) async {
      const chatEditorState = ChatEditorWaitingForFirstMessage(
        chatMembers: [currentUser, otherUser],
      );

      await tester.pumpWidget(
        buildWidget(
          chatEditorState: chatEditorState,
          chatMessagesState: const ChatMessagesLoading(
            chatId: '',
            chatMessages: [],
            pageNumber: 1,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '  First hello  ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verify(
        () => chatEditorBloc.add(
          any(
            that: isA<AddChatFirstMessage>().having(
              (event) => event.firstMessageContent,
              'firstMessageContent',
              'First hello',
            ),
          ),
        ),
      ).called(1);
      expect(find.text('First hello'), findsNothing);
    },
  );

  testWidgets(
    'given the chat editor is not loaded when a descendant reads '
    'ChatMessagesBloc then the provider creates it without dispatching the '
    'initial load',
    (tester) async {
      await tester.pumpWidget(
        buildWidget(
          chatEditorState: const ChatEditorWaitingForFirstMessage(
            chatMembers: [currentUser, otherUser],
          ),
          chatMessagesState: const ChatMessagesLoading(
            chatId: '',
            chatMessages: [],
            pageNumber: 1,
          ),
        ),
      );

      BlocProvider.of<ChatMessagesBloc>(tester.element(find.byType(Scaffold)));

      verifyNever(
        () => chatMessagesBloc.add(
          any(that: isA<LoadInitialChatMessagesPage>()),
        ),
      );
    },
  );

  testWidgets(
    'given the chat editor is loading when the page is rendered then the '
    'send button shows a loader',
    (tester) async {
      await tester.pumpWidget(
        buildWidget(
          chatEditorState: const ChatEditorLoading(chatMembers: [otherUser]),
          chatMessagesState: const ChatMessagesLoading(
            chatId: '',
            chatMessages: [],
            pageNumber: 1,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets(
    'given the chat editor becomes loaded after the page is built then the '
    'listener dispatches the initial page load',
    (tester) async {
      await tester.pumpWidget(
        buildWidget(
          chatEditorState: const ChatEditorWaitingForFirstMessage(
            chatMembers: [currentUser, otherUser],
          ),
          chatMessagesState: const ChatMessagesLoading(
            chatId: '',
            chatMessages: [],
            pageNumber: 1,
          ),
        ),
      );

      chatEditorStateController.add(
        const ChatEditorLoaded(
          chatMembers: [currentUser, otherUser],
          chatId: 'chat-1',
        ),
      );
      await tester.pump();

      verify(
        () => chatMessagesBloc.add(
          any(
            that: isA<LoadInitialChatMessagesPage>().having(
              (event) => event.chatId,
              'chatId',
              'chat-1',
            ),
          ),
        ),
      ).called(2);
    },
  );
}
