import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_message_card.dart';

class MockChatEditorBloc extends MockBloc<ChatEditorEvent, ChatEditorState>
    implements ChatEditorBloc {}

void main() {
  late MockChatEditorBloc chatEditorBloc;

  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025, 1, 1, 10),
    updatedAt: DateTime(2025, 1, 1, 10),
  );

  setUp(() {
    chatEditorBloc = MockChatEditorBloc();
  });

  Widget buildWidget({required ChatEditorState state, required bool isMe}) {
    when(() => chatEditorBloc.state).thenReturn(state);
    whenListen(chatEditorBloc, Stream.value(state));

    return MaterialApp(
      home: BlocProvider<ChatEditorBloc>.value(
        value: chatEditorBloc,
        child: Scaffold(
          body: ChatMessageCard(
            isMe: isMe,
            chatMessage: message,
            authorName: 'Alice',
          ),
        ),
      ),
    );
  }

  testWidgets(
    'given a message from the current user when the widget is rendered then '
    'it hides the author name',
    (tester) async {
      // Act
      await tester.pumpWidget(
        buildWidget(
          state: const ChatEditorLoaded(
            chatId: 'chat-1',
            chatMembers: [
              UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
              UserEntity(id: 'user-2', name: 'Bob', email: 'bob@test.com'),
            ],
          ),
          isMe: true,
        ),
      );

      // Assert
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    },
  );

  testWidgets(
    'given a group chat message from another user when the widget is '
    'rendered then it shows the author name',
    (tester) async {
      // Act
      await tester.pumpWidget(
        buildWidget(
          state: const ChatEditorLoaded(
            chatId: 'chat-1',
            chatMembers: [
              UserEntity(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
              UserEntity(id: 'user-2', name: 'Bob', email: 'bob@test.com'),
              UserEntity(id: 'user-3', name: 'Cara', email: 'cara@test.com'),
            ],
          ),
          isMe: false,
        ),
      );

      // Assert
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    },
  );
}
