import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_chat_messages_count.dart';

class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  late MockChatMessageRepository chatMessageRepository;
  late GetChatMessagesCount usecase;

  setUp(() {
    chatMessageRepository = MockChatMessageRepository();
    usecase = GetChatMessagesCount(
      chatMessageRepository: chatMessageRepository,
    );
  });

  test(
    'given a chat id when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => chatMessageRepository.getChatMessagesCount('chat-1'),
      ).thenAnswer((_) async => right<Failure, int>(3));

      // Act
      final result = await usecase('chat-1');

      // Assert
      expect(result, right<Failure, int>(3));
      verify(
        () => chatMessageRepository.getChatMessagesCount('chat-1'),
      ).called(1);
    },
  );
}
