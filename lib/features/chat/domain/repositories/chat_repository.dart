import 'package:fpdart/fpdart.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/features/chat/domain/entities/chat.dart';
import 'package:social_app/features/chat/domain/pagination/chat_candidates_slice.dart';
import 'package:social_app/features/chat/domain/events/chat_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_feed_slice.dart';
import 'package:social_app/features/chat/domain/events/chat_message_change.dart';
import 'package:social_app/features/chat/domain/pagination/chat_message_feed_slice.dart';
import 'package:social_app/features/chat/domain/results/chat_write_result.dart';

/// Domain contract aligned with the remote chat API.
abstract interface class ChatRepository {
  /// Fetches one cursor-based slice of chat candidates.
  Future<Either<Failure, ChatCandidatesSlice>> getChatCandidatesSlice({
    required int limit,
    String? cursor,
  });

  /// Creates one new chat with its first message.
  Future<Either<Failure, ChatWriteResult>> createChat({
    required List<String> memberIds,
    required String firstMessageContent,
  });

  /// Fetches one cursor-based slice of chats ordered by recent activity.
  Future<Either<Failure, ChatFeedSlice>> getChatFeedSlice({
    required int limit,
    String? cursor,
  });

  /// Opens the realtime chat-feed event stream.
  Stream<Either<Failure, ChatChange>> watchChatFeedEvents();

  /// Looks up one existing chat by its exact member set.
  /// The current user is implicitly included in the member set.
  /// Passing it explicitly is optional but allowed for convenience.
  Future<Either<Failure, Chat?>> getChatByMembers({
    required List<String> memberIds,
  });

  /// Fetches one cursor-based slice of messages inside the target chat.
  Future<Either<Failure, ChatMessageFeedSlice>> getChatMessageFeedSlice({
    required String chatId,
    required int limit,
    String? cursor,
  });

  /// Creates one new message inside the target chat.
  Future<Either<Failure, ChatWriteResult>> createChatMessage({
    required String chatId,
    required String content,
  });

  /// Opens the realtime chat-message event stream.
  Stream<Either<Failure, ChatMessageChange>> watchChatMessageChanges();
}
