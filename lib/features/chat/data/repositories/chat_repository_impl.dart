// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_app/features/chat/data/models/chat_model.dart';
import 'package:fpdart/fpdart.dart';

import 'package:bloc_app/core/errors/exceptions.dart';
import 'package:bloc_app/core/errors/failures.dart';
import 'package:bloc_app/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:bloc_app/features/chat/domain/entities/chat.dart';
import 'package:bloc_app/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRemoteDataSource chatRemoteDataSource;
  ChatRepositoryImpl({required this.chatRemoteDataSource});

  @override
  Future<Either<ServerFailure, Chat>> createChat(List<String> memberIds) async {
    try {
      ChatModel chat = await chatRemoteDataSource.createChat(memberIds);
      return Right(chat.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
