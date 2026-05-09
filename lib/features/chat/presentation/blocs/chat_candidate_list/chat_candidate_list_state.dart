part of 'chat_candidate_list_bloc.dart';

@immutable
/// Represents the chat-candidate list state.
sealed class ChatCandidateListState {
  /// Creates a [ChatCandidateListState].
  const ChatCandidateListState({
    required this.candidates,
    required this.nextCursor,
  });

  /// Candidate users currently rendered in the list.
  final List<ChatUserSummary> candidates;

  /// Remote cursor used to request the next slice, when available.
  final String? nextCursor;
}

/// State emitted while the candidate list is loading.
final class ChatCandidateListLoading extends ChatCandidateListState {
  /// Creates a [ChatCandidateListLoading].
  const ChatCandidateListLoading({
    required super.candidates,
    required super.nextCursor,
  });
}

/// State emitted when at least one candidate slice has been loaded.
final class ChatCandidateListSuccess extends ChatCandidateListState {
  /// Creates a [ChatCandidateListSuccess].
  const ChatCandidateListSuccess({
    required super.candidates,
    required super.nextCursor,
  });
}

/// State emitted when loading the candidate list fails.
final class ChatCandidateListFailure extends ChatCandidateListState {
  /// Creates a [ChatCandidateListFailure].
  const ChatCandidateListFailure({
    required this.error,
    required super.candidates,
    required super.nextCursor,
  });

  /// Error shown to the user when the candidate list could not be loaded.
  final String error;
}
