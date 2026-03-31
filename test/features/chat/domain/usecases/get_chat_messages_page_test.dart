import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_messages_page.dart';

class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  late MockChatMessageRepository chatMessageRepository;
  late GetChatMessagesPage usecase;

  final messages = [
    ChatMessage(
      id: 'message-1',
      authorId: 'user-1',
      content: 'Hello',
      createdAt: DateTime(2025),
      updatedAt: DateTime(2025),
    ),
  ];

  setUp(() {
    chatMessageRepository = MockChatMessageRepository();
    usecase = GetChatMessagesPage(chatMessageRepository: chatMessageRepository);
  });

  test(
    'given page params when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => chatMessageRepository.getChatMessagesPage(2, 'chat-1'),
      ).thenAnswer((_) async => right<Failure, List<ChatMessage>>(messages));

      // Act
      final result = await usecase(
        GetChatMessagesPageParams(pageNumber: 2, chatId: 'chat-1'),
      );

      // Assert
      expect(result, right<Failure, List<ChatMessage>>(messages));
      verify(
        () => chatMessageRepository.getChatMessagesPage(2, 'chat-1'),
      ).called(1);
    },
  );
}
