import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ChatRepository {
  Future<Either<Failure, Chat>> createChat(List<String> memberIds);
}
