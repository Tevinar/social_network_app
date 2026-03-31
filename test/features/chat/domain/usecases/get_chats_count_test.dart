import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/usecases/usecase.dart';
import 'package:social_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:social_app/features/chat/domain/usecases/get_chats_count.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;
  late GetChatsCount usecase;

  setUp(() {
    chatRepository = MockChatRepository();
    usecase = GetChatsCount(chatRepository: chatRepository);
  });

  test(
    'given NoParams when call is invoked then delegates to the repository',
    () async {
      // Arrange
      when(
        () => chatRepository.getChatsCount(),
      ).thenAnswer((_) async => right<Failure, int>(2));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, right<Failure, int>(2));
      verify(() => chatRepository.getChatsCount()).called(1);
    },
  );
}
