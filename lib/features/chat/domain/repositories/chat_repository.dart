import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_candidate_list_slice.dart';
import 'package:social_app/features/chat/domain/pagination/chat_list_slice.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_list_slice.dart';
import 'package:social_app/features/chat/domain/results/chat_write_result.dart';

/// Domain contract aligned with the remote chat API.
abstract interface class ChatRepository {
  /// Fetches one cursor-based slice of chat candidates.
  Future<Either<Failure, ChatCandidateListSlice>> getChatCandidateListSlice({
    required int limit,
    String? cursor,
  });

  /// Creates one new chat with its first message.
  Future<Either<Failure, ChatWriteResult>> createChat({
    required List<String> memberIds,
    required String firstMessageContent,
  });

  /// Fetches one cursor-based slice of chats ordered by recent activity.
  Future<Either<Failure, ChatListSlice>> getChatListSlice({
    required int limit,
    String? cursor,
  });

  /// Opens the realtime chat-list event stream.
  Stream<Either<Failure, ChatListChange>> subscribeToChatList();

  /// Looks up one existing chat by its exact member set.
  /// The current user is implicitly included in the member set.
  /// Passing it explicitly is optional but allowed for convenience.
  Future<Either<Failure, Chat?>> getChatByMembers({
    required List<String> memberIds,
  });

  /// Fetches one cursor-based slice of messages inside the target chat.
  Future<Either<Failure, ChatMessageListSlice>> getChatMessageListSlice({
    required String chatId,
    required int limit,
    String? cursor,
  });

  /// Creates one new message inside the target chat.
  Future<Either<Failure, ChatWriteResult>> createChatMessage({
    required String chatId,
    required String content,
  });

  /// Opens the realtime chat-message event stream for one chat.
  Stream<Either<Failure, ChatMessageListChange>> subscribeToChatMessageList({
    required String chatId,
  });
}
