import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/auth/domain/entities/user_entity.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/entities/chat_change.dart';
import 'package:social_app/features/chat/domain/entities/chat_message.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/usecases/watch_chat_changes.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;
  late WatchChatChanges watchChatChanges;

  const user = UserEntity(
    id: 'user-1',
    name: 'Alice',
    email: 'alice@test.com',
  );

  final message = ChatMessage(
    id: 'message-1',
    authorId: 'user-1',
    content: 'Hello',
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  final chat = Chat(
    id: 'chat-1',
    lastMessage: message,
    members: const [user],
  );

  setUp(() {
    chatRepository = MockChatRepository();
    watchChatChanges = WatchChatChanges(chatRepository: chatRepository);
  });

  test(
    'given the use case is called when the repository emits chat changes then '
    'it forwards the stream',
    () async {
      final change = ChatInserted(chat);

      when(() => chatRepository.watchChatChanges()).thenAnswer(
        (_) => Stream.value(right<Failure, ChatChange>(change)),
      );

      final emissions = await watchChatChanges(const NoParams()).toList();

      expect(emissions, [right<Failure, ChatChange>(change)]);
      verify(() => chatRepository.watchChatChanges()).called(1);
    },
  );
}
