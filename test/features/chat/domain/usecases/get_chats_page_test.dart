import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_chats_page.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;
  late GetChatsPage usecase;

  final chats = [
    Chat(
      id: 'chat-1',
      lastMessage: ChatMessage(
        id: 'message-1',
        authorId: 'user-1',
        content: 'Hello',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      ),
      members: const [
        User(id: 'user-1', name: 'Alice', email: 'alice@test.com'),
      ],
    ),
  ];

  setUp(() {
    chatRepository = MockChatRepository();
    usecase = GetChatsPage(chatRepository: chatRepository);
  });

  test(
    'given a page number when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => chatRepository.getChatsPage(2),
      ).thenAnswer((_) async => right<Failure, List<Chat>>(chats));

      // Act
      final result = await usecase(2);

      // Assert
      expect(result, right<Failure, List<Chat>>(chats));
      verify(() => chatRepository.getChatsPage(2)).called(1);
    },
  );
}
