import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/use_cases/use_case.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/entities/chat_message_change.dart';
import 'package:social_app/features/chat/domain/repositories/chat_message_repository.dart';
import 'package:social_app/features/chat/domain/usecases/watch_chat_message_changes.dart';

class MockChatMessageRepository extends Mock implements ChatMessageRepository {}

void main() {
  late MockChatMessageRepository chatMessageRepository;
  late WatchChatMessageChanges watchChatMessageChanges;

  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  setUp(() {
    chatMessageRepository = MockChatMessageRepository();
    watchChatMessageChanges = WatchChatMessageChanges(
      chatMessageRepository: chatMessageRepository,
    );
  });

  test(
    'given the use case is called when the repository emits chat message '
    'changes then it forwards the stream',
    () async {
      final change = ChatMessageInserted(
        chatId: 'chat-1',
        chatMessage: message,
      );

      when(() => chatMessageRepository.watchChatMessageChanges()).thenAnswer(
        (_) => Stream.value(right<Failure, ChatMessageChange>(change)),
      );

      final emissions = await watchChatMessageChanges(
        const NoParams(),
      ).toList();

      expect(emissions, [right<Failure, ChatMessageChange>(change)]);
      verify(() => chatMessageRepository.watchChatMessageChanges()).called(1);
    },
  );
}
