import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/user/users_bloc.dart';
import 'package:social_app/features/chat/presentation/pages/new_chat_page.dart';

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

class MockUsersBloc extends MockBloc<UsersEvent, UsersState>
    implements UsersBloc {}

class MockChatEditorBloc extends MockBloc<ChatEditorEvent, ChatEditorState>
    implements ChatEditorBloc {}

void main() {
  late MockAppUserCubit appUserCubit;
  late MockUsersBloc usersBloc;
  late MockChatEditorBloc chatEditorBloc;
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
  const thirdUser = UserEntity(
    id: 'user-3',
    name: 'Cara',
    email: 'cara@test.com',
  );

  setUpAll(() {
    registerFallbackValue(AddChat(chatMembers: const [currentUser]));
  });

  setUp(() {
    appUserCubit = MockAppUserCubit();
    usersBloc = MockUsersBloc();
    chatEditorBloc = MockChatEditorBloc();
    scrollController = ScrollController();
    chatEditorStateController = StreamController<ChatEditorState>.broadcast();

    when(
      () => appUserCubit.state,
    ).thenReturn(const AppUserSignedIn(currentUser));
    whenListen(appUserCubit, Stream.value(const AppUserSignedIn(currentUser)));
    when(() => usersBloc.scrollController).thenReturn(scrollController);
    when(() => chatEditorBloc.state).thenReturn(
      const ChatEditorDrafted(chatMembers: []),
    );
    whenListen(
      chatEditorBloc,
      chatEditorStateController.stream,
      initialState: const ChatEditorDrafted(chatMembers: []),
    );
  });

  tearDown(() async {
    await chatEditorStateController.close();
  });

  Widget buildWidget({
    required UsersState usersState,
    ChatEditorState chatEditorState = const ChatEditorDrafted(chatMembers: []),
  }) {
    when(() => usersBloc.state).thenReturn(usersState);
    whenListen(usersBloc, Stream.value(usersState));
    when(() => chatEditorBloc.state).thenReturn(chatEditorState);

    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppUserCubit>.value(value: appUserCubit),
          BlocProvider<UsersBloc>.value(value: usersBloc),
          BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
        ],
        child: const NewChatPage(),
      ),
    );
  }

  Widget buildRoutableWidget({
    required UsersState usersState,
    ChatEditorState chatEditorState = const ChatEditorDrafted(chatMembers: []),
  }) {
    when(() => usersBloc.state).thenReturn(usersState);
    whenListen(usersBloc, Stream.value(usersState));
    when(() => chatEditorBloc.state).thenReturn(chatEditorState);

    final router = GoRouter(
      initialLocation: '/new-chat',
      routes: [
        GoRoute(
          path: '/new-chat',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppUserCubit>.value(value: appUserCubit),
              BlocProvider<UsersBloc>.value(value: usersBloc),
              BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
            ],
            child: const NewChatPage(),
          ),
        ),
        GoRoute(
          path: '/chat-messages',
          builder: (context, state) => const Scaffold(body: Text('Messages')),
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  testWidgets('shows the error body when users loading fails', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        usersState: const UsersFailure(error: 'boom', users: [], pageNumber: 1),
      ),
    );

    expect(find.text('Error loading users : boom'), findsOneWidget);
  });

  testWidgets('shows a loader while the first page of users is loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(usersState: const UsersLoading(users: [], pageNumber: 1)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows users except the current user', (tester) async {
    await tester.pumpWidget(
      buildWidget(
        usersState: const UsersSuccess(
          users: [currentUser, otherUser],
          pageNumber: 1,
          totalUsersInDatabase: 2,
        ),
      ),
    );

    expect(find.text('Alice'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('selecting and unselecting a user toggles the message button', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(
        usersState: const UsersSuccess(
          users: [currentUser, otherUser],
          pageNumber: 1,
          totalUsersInDatabase: 2,
        ),
      ),
    );

    expect(find.text('Message'), findsNothing);
    await tester.tap(find.text('Bob'));
    await tester.pump();
    expect(find.text('Message'), findsOneWidget);

    await tester.tap(find.text('Bob'));
    await tester.pump();
    expect(find.text('Message'), findsNothing);
  });

  testWidgets(
    'tapping the message button dispatches AddChat with the selected users '
    'and the current user',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildWidget(
          usersState: const UsersSuccess(
            users: [currentUser, otherUser, thirdUser],
            pageNumber: 1,
            totalUsersInDatabase: 3,
          ),
        ),
      );

      await tester.tap(find.text('Bob'));
      await tester.pump();
      tester.widget<TextButton>(find.byType(TextButton)).onPressed!.call();
      await tester.pump();

      verify(
        () => chatEditorBloc.add(
          any(
            that: isA<AddChat>().having(
              (event) => event.chatMembers.map((user) => user.id).toList(),
              'chatMembers',
              [otherUser.id, currentUser.id],
            ),
          ),
        ),
      ).called(1);
    },
  );

  testWidgets(
    'when the chat editor is loading and a user is selected then the button '
    'shows a loader and does not dispatch AddChat',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildWidget(
          usersState: const UsersSuccess(
            users: [currentUser, otherUser],
            pageNumber: 1,
            totalUsersInDatabase: 2,
          ),
          chatEditorState: const ChatEditorLoading(chatMembers: [otherUser]),
        ),
      );

      await tester.tap(find.text('Bob'));
      await tester.pump();
      tester.widget<TextButton>(find.byType(TextButton)).onPressed!.call();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      verifyNever(() => chatEditorBloc.add(any()));
    },
  );

  testWidgets(
    'when the chat editor emits a loaded state after a selection then it '
    'navigates to chat messages',
    (tester) async {
      await tester.pumpWidget(
        buildRoutableWidget(
          usersState: const UsersSuccess(
            users: [currentUser, otherUser],
            pageNumber: 1,
            totalUsersInDatabase: 2,
          ),
        ),
      );

      await tester.tap(find.text('Bob'));
      await tester.pump();
      chatEditorStateController.add(
        const ChatEditorLoaded(chatMembers: [otherUser], chatId: 'chat-1'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);
    },
  );

  testWidgets('shows the next-page loader when more users exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildWidget(
        usersState: const UsersSuccess(
          users: [currentUser, otherUser],
          pageNumber: 1,
          totalUsersInDatabase: 3,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
