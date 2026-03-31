import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:social_app/features/chat/domain/usecases/create_chat_message.dart';

class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  late MockChatMessageRepository chatMessageRepository;
  late CreateChatMessage usecase;

  setUp(() {
    chatMessageRepository = MockChatMessageRepository();
    usecase = CreateChatMessage(chatMessageRepository: chatMessageRepository);
  });

  test(
    'given an empty trimmed content when call is invoked then returns '
    'ValidationFailure',
    () async {
      // Act
      final result = await usecase(
        CreateChatMessageParams(chatId: 'chat-1', content: '   '),
      );

      // Assert
      expect(
        result,
        left<Failure, void>(
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
        () => chatMessageRepository.createChatMessage(
          chatId: 'chat-1',
          content: 'Hello',
        ),
      ).thenAnswer((_) async => right<Failure, void>(null));

      // Act
      final result = await usecase(
        CreateChatMessageParams(chatId: 'chat-1', content: 'Hello'),
      );

      // Assert
      expect(result, right<Failure, void>(null));
      verify(
        () => chatMessageRepository.createChatMessage(
          chatId: 'chat-1',
          content: 'Hello',
        ),
      ).called(1);
    },
  );
}
