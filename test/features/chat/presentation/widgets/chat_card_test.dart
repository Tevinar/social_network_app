import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/ui/formatting/format_date.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_card.dart';

class MockAppUserCubit extends MockCubit<AppUserState>
    implements AppUserCubit {}

class MockChatEditorBloc extends MockBloc<ChatEditorEvent, ChatEditorState>
    implements ChatEditorBloc {}

void main() {
  late MockAppUserCubit appUserCubit;
  late MockChatEditorBloc chatEditorBloc;

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
    registerFallbackValue(
      SelectChat(chatId: '', chatMembers: const [currentUser]),
    );
  });

  setUp(() {
    appUserCubit = MockAppUserCubit();
    chatEditorBloc = MockChatEditorBloc();

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
  });

  Widget buildWidget(Chat chat) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppUserCubit>.value(value: appUserCubit),
        BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
      ],
      child: MaterialApp(
        home: Scaffold(body: ChatCard(chat: chat)),
      ),
    );
  }

  Widget buildRoutableWidget(Chat chat) {
    final router = GoRouter(
      initialLocation: '/chats',
      routes: [
        GoRoute(
          path: '/chats',
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider<AppUserCubit>.value(value: appUserCubit),
              BlocProvider<ChatEditorBloc>.value(value: chatEditorBloc),
            ],
            child: Scaffold(body: ChatCard(chat: chat)),
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

  testWidgets(
    'given a chat updated today when ChatCard is rendered then it shows the '
    'other members names and the formatted hour',
    (tester) async {
      final now = DateTime.now();
      final chat = Chat(
        id: 'chat-1',
        lastMessage: ChatMessage(
          id: 'message-1',
          authorId: currentUser.id,
          content: 'Hello today',
          createdAt: now,
          updatedAt: now,
        ),
        members: const [currentUser, otherUser, thirdUser],
      );

      await tester.pumpWidget(buildWidget(chat));

      expect(find.text('Bob, Cara'), findsOneWidget);
      expect(find.text('Hello today'), findsOneWidget);
      expect(find.text(formatToHour(now)), findsOneWidget);
    },
  );

  testWidgets(
    'given a chat updated on another day when ChatCard is rendered then it '
    'shows the formatted day',
    (tester) async {
      final date = DateTime(2025, 1, 1, 10);
      final chat = Chat(
        id: 'chat-1',
        lastMessage: ChatMessage(
          id: 'message-1',
          authorId: currentUser.id,
          content: 'Hello old',
          createdAt: date,
          updatedAt: date,
        ),
        members: const [currentUser, otherUser],
      );

      await tester.pumpWidget(buildWidget(chat));

      expect(find.text('Bob'), findsOneWidget);
      expect(find.text(formatToDay(date)), findsOneWidget);
    },
  );

  testWidgets(
    'given a chat card when it is tapped then it dispatches SelectChat and '
    'navigates to chat messages',
    (tester) async {
      final date = DateTime(2025, 1, 1, 10);
      final chat = Chat(
        id: 'chat-1',
        lastMessage: ChatMessage(
          id: 'message-1',
          authorId: currentUser.id,
          content: 'Hello',
          createdAt: date,
          updatedAt: date,
        ),
        members: const [currentUser, otherUser],
      );

      await tester.pumpWidget(buildRoutableWidget(chat));
      await tester.tap(find.byType(ChatCard));
      await tester.pumpAndSettle();

      verify(
        () => chatEditorBloc.add(
          any(
            that: isA<SelectChat>()
                .having((event) => event.chatId, 'chatId', 'chat-1')
                .having(
                  (event) => event.chatMembers,
                  'chatMembers',
                  const [currentUser, otherUser],
                ),
          ),
        ),
      ).called(1);
      expect(find.text('Messages'), findsOneWidget);
    },
  );
}
