import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_by_members.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;
  late GetChatByMembers usecase;

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
    usecase = GetChatByMembers(chatRepository: chatRepository);
  });

  test(
    'given members when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => chatRepository.getChatByMembers(const [user]),
      ).thenAnswer((_) async => right<Failure, Chat?>(chat));

      // Act
      final result = await usecase(
        GetChatByMembersParams(members: const [user]),
      );

      // Assert
      expect(result, right<Failure, Chat?>(chat));
      verify(() => chatRepository.getChatByMembers(const [user])).called(1);
    },
  );
}
