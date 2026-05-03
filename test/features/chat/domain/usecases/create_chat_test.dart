import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/usecases/create_chat.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;
  late CreateChat usecase;

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

  setUp(() {
    chatRepository = MockChatRepository();
    usecase = CreateChat(chatRepository: chatRepository);
  });

  test(
    'given an empty trimmed first message when call is invoked then returns '
    'ValidationFailure',
    () async {
      // Act
      final result = await usecase(
        CreateChatParams(members: const [user], firstMessageContent: '   '),
      );

      // Assert
      expect(
        result,
        left<Failure, Chat>(
          const ValidationFailure('Message cannot be empty'),
        ),
      );
    },
  );

  test(
    'given valid params when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => chatRepository.createChat(const [user], 'Hello'),
      ).thenAnswer((_) async => right<Failure, Chat>(chat));

      // Act
      final result = await usecase(
        CreateChatParams(members: const [user], firstMessageContent: 'Hello'),
      );

      // Assert
      expect(result, right<Failure, Chat>(chat));
      verify(() => chatRepository.createChat(const [user], 'Hello')).called(1);
    },
  );
}
