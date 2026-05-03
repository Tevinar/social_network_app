import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/usecases/create_chat.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_by_members.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';

class MockCreateChat extends Mock implements CreateChat {}

class MockGetChatByMembers extends Mock implements GetChatByMembers {}

class FakeCreateChatParams extends Fake implements CreateChatParams {}

class FakeGetChatByMembersParams extends Fake
    implements GetChatByMembersParams {}

void main() {
  late MockCreateChat createChat;
  late MockGetChatByMembers getChatByMembers;

  const user = UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com');
  final chat = Chat(
    id: 'chat-1',
    lastMessage: ChatMessage(
      id: 'message-1',
      authorId: 'user-1',
      content: 'Hello',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
    members: const [user],
  );

  setUpAll(() {
    registerFallbackValue(
      CreateChatParams(members: const [user], firstMessageContent: ''),
    );
    registerFallbackValue(GetChatByMembersParams(members: const [user]));
    registerFallbackValue(FakeCreateChatParams());
    registerFallbackValue(FakeGetChatByMembersParams());
  });

  setUp(() {
    createChat = MockCreateChat();
    getChatByMembers = MockGetChatByMembers();
  });

  test(
    'given the bloc is created when reading state then state is '
    'ChatEditorDrafted',
    () {
      // Act
      final bloc = ChatEditorBloc(
        createChat: createChat,
        getChatByMembers: getChatByMembers,
      );
      addTearDown(bloc.close);

      // Assert
      expect(bloc.state, const TypeMatcher<ChatEditorDrafted>());
      expect(bloc.state.chatMembers, isEmpty);
    },
  );

  blocTest<ChatEditorBloc, ChatEditorState>(
    'given getChatByMembers returns null when AddChat is added then emits '
    'Loading and WaitingForFirstMessage',
    build: () {
      when(
        () => getChatByMembers(any()),
      ).thenAnswer((_) async => const Right(null));
      return ChatEditorBloc(
        createChat: createChat,
        getChatByMembers: getChatByMembers,
      );
    },
    act: (bloc) => bloc.add(AddChat(chatMembers: const [user])),
    expect: () => [
      isA<ChatEditorLoading>(),
      isA<ChatEditorWaitingForFirstMessage>(),
    ],
  );

  blocTest<ChatEditorBloc, ChatEditorState>(
    'given getChatByMembers returns a chat when AddChat is added then emits '
    'Loading and Loaded',
    build: () {
      when(() => getChatByMembers(any())).thenAnswer((_) async => Right(chat));
      return ChatEditorBloc(
        createChat: createChat,
        getChatByMembers: getChatByMembers,
      );
    },
    act: (bloc) => bloc.add(AddChat(chatMembers: const [user])),
    expect: () => [
      isA<ChatEditorLoading>(),
      isA<ChatEditorLoaded>()
          .having((state) => state.chatId, 'chatId', 'chat-1')
          .having((state) => state.chatMembers, 'chatMembers', const [user]),
    ],
  );

  blocTest<ChatEditorBloc, ChatEditorState>(
    'given getChatByMembers fails when AddChat is added then emits Loading '
    'and Failure',
    build: () {
      when(() => getChatByMembers(any())).thenAnswer(
        (_) async => left(const NetworkFailure()),
      );
      return ChatEditorBloc(
        createChat: createChat,
        getChatByMembers: getChatByMembers,
      );
    },
    act: (bloc) => bloc.add(AddChat(chatMembers: const [user])),
    expect: () => [
      isA<ChatEditorLoading>(),
      isA<ChatEditorFailure>()
          .having(
            (state) => state.message,
            'message',
            'No internet connection.',
          )
          .having((state) => state.chatMembers, 'chatMembers', const [user]),
    ],
  );

  blocTest<ChatEditorBloc, ChatEditorState>(
    'given createChat succeeds when AddChatFirstMessage is added then emits '
    'Loading and Loaded',
    build: () {
      when(() => createChat(any())).thenAnswer((_) async => Right(chat));
      return ChatEditorBloc(
        createChat: createChat,
        getChatByMembers: getChatByMembers,
      );
    },
    seed: () => const ChatEditorWaitingForFirstMessage(chatMembers: [user]),
    act: (bloc) => bloc.add(AddChatFirstMessage(firstMessageContent: 'Hello')),
    expect: () => [
      isA<ChatEditorLoading>(),
      isA<ChatEditorLoaded>().having(
        (state) => state.chatId,
        'chatId',
        'chat-1',
      ),
    ],
    verify: (_) {
      verify(
        () => createChat(
          any(
            that: isA<CreateChatParams>()
                .having((p) => p.members, 'members', const [user])
                .having(
                  (p) => p.firstMessageContent,
                  'firstMessageContent',
                  'Hello',
                ),
          ),
        ),
      ).called(1);
    },
  );

  blocTest<ChatEditorBloc, ChatEditorState>(
    'given createChat fails when AddChatFirstMessage is added then emits '
    'Loading and Failure',
    build: () {
      when(() => createChat(any())).thenAnswer(
        (_) async => left(const ValidationFailure('Invalid message')),
      );
      return ChatEditorBloc(
        createChat: createChat,
        getChatByMembers: getChatByMembers,
      );
    },
    seed: () => const ChatEditorWaitingForFirstMessage(chatMembers: [user]),
    act: (bloc) => bloc.add(AddChatFirstMessage(firstMessageContent: 'Hello')),
    expect: () => [
      isA<ChatEditorLoading>(),
      isA<ChatEditorFailure>().having(
        (state) => state.message,
        'message',
        'Invalid message',
      ),
    ],
  );

  blocTest<ChatEditorBloc, ChatEditorState>(
    'given SelectChat is added when the bloc handles it then emits Loaded',
    build: () => ChatEditorBloc(
      createChat: createChat,
      getChatByMembers: getChatByMembers,
    ),
    act: (bloc) =>
        bloc.add(SelectChat(chatId: 'chat-1', chatMembers: const [user])),
    expect: () => [
      isA<ChatEditorLoaded>()
          .having((state) => state.chatId, 'chatId', 'chat-1')
          .having((state) => state.chatMembers, 'chatMembers', const [user]),
    ],
  );
}
