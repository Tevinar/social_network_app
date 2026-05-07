import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';

/// Domain entity representing one cursor-based slice of chat candidates.
class ChatCandidatesSlice {
  /// Creates a [ChatCandidatesSlice].
  const ChatCandidatesSlice({
    required this.candidates,
    required this.nextCursor,
  });

  /// Candidate users returned in the current slice.
  final List<ChatUserSummary> candidates;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
