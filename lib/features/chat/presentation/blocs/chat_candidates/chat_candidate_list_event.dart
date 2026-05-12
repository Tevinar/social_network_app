part of 'chat_candidate_list_bloc.dart';

@immutable
/// Base type for chat-candidate list events.
sealed class ChatCandidateListEvent {
  const ChatCandidateListEvent();
}

/// Requests loading the next candidate slice, if available.
class LoadChatCandidateListNextSlice extends ChatCandidateListEvent {
  /// Creates a [LoadChatCandidateListNextSlice].
  const LoadChatCandidateListNextSlice();
}
