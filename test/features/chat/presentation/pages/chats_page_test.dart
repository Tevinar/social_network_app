import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chats/chats_bloc.dart';
import 'package:social_app/features/chat/presentation/pages/chats_page.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_card.dart';

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

class MockChatEditorBloc extends MockBloc<ChatEditorEvent, ChatEditorState>
    implements ChatEditorBloc {}

class MockChatsBloc extends MockBloc<ChatsEvent, ChatsState>
    implements ChatsBloc {}

void main() {
  late MockAppUserCubit appUserCubit;
  late MockChatEditorBloc chatEditorBloc;
  late MockChatsBloc chatsBloc;
  late ScrollController scrollController;

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
  final chat = Chat(
    id: 'chat-1',
    lastMessage: ChatMessage(
      id: 'message-1',
      authorId: currentUser.id,
      content: 'Hello',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    members: const [currentUser, otherUser],
  );

  setUp(() {
    appUserCubit = MockAppUserCubit();
    chatEditorBloc = MockChatEditorBloc();
    chatsBloc = MockChatsBloc();
    scrollController = ScrollController();

    when(
      () => appUserCubit.state,
    ).thenReturn(const AppUserSignedIn(currentUser));
    whenListen(appUserCubit, Stream.value(const AppUserSignedIn(currentUser)));
    when(() => chatEditorBloc.state).thenReturn(
      const ChatEditorDrafted(chatMembers: []),
    );
    whenListen(
      chatEditorBloc,
      Stream.value(const ChatEditorDrafted(chatMembers: [])),
    );
    when(() => chatsBloc.scrollController).thenReturn(scrollController);
  });

  Widget buildWidget(ChatsState state) {
    when(() => chatsBloc.state).thenReturn(state);
    whenListen(chatsBloc, Stream.value(state));

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppUserCubit>.value(value: appUserCubit),
          BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
          BlocProvider<ChatsBloc>.value(value: chatsBloc),
        ],
        child: const ChatsPage(),
      ),
    );
  }

  Widget buildRoutableWidget(ChatsState state) {
    when(() => chatsBloc.state).thenReturn(state);
    whenListen(chatsBloc, Stream.value(state));

    final router = GoRouter(
      initialLocation: '/chats',
      routes: [
        GoRoute(
          path: '/chats',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppUserCubit>.value(value: appUserCubit),
              BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
              BlocProvider<ChatsBloc>.value(value: chatsBloc),
            ],
            child: const ChatsPage(),
          ),
        ),
        GoRoute(
          path: '/new-chat',
          builder: (context, state) => const Scaffold(body: Text('New Chat')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows the error body when chats loading fails', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        const ChatsFailure(error: 'boom', chats: [], pageNumber: 1),
      ),
    );

    expect(find.text('Error loading chats : boom'), findsOneWidget);
  });

  testWidgets('shows a loader while the first page of chats is loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(const ChatsLoading(chats: [], pageNumber: 1)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no chats', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        const ChatsSuccess(chats: [], pageNumber: 1, totalChatsInDatabase: 0),
      ),
    );

    expect(
      find.text("You don't have any chats. Start a new one!"),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows the chat list and the next-page loader when more chats exist',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget(
          ChatsSuccess(chats: [chat], pageNumber: 2, totalChatsInDatabase: 2),
        ),
      );

      expect(find.byType(ChatCard), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('navigates to the new chat page when the fab is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildRoutableWidget(
        ChatsSuccess(chats: [chat], pageNumber: 2, totalChatsInDatabase: 1),
      ),
    );
    await tester.tap(find.byIcon(Icons.add_box_rounded));
    await tester.pumpAndSettle();

    expect(find.text('New Chat'), findsOneWidget);
  });
}
