import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_user_summary_model.dart';

/// Data-layer representation of one cursor-based chat-candidates slice.
class ChatCandidatesSliceModel {
  /// Creates a [ChatCandidatesSliceModel].
  const ChatCandidatesSliceModel({
    required this.candidates,
    required this.nextCursor,
  });

  /// Builds a [ChatCandidatesSliceModel] from a backend JSON payload.
  factory ChatCandidatesSliceModel.fromJson(Map<String, dynamic> json) {
    final candidates = JsonReader.readList(json, 'candidates');

    return ChatCandidatesSliceModel(
      candidates: candidates
          .map(
            (candidate) => ChatUserSummaryModel.fromJson(
              JsonReader.asObject(candidate, 'candidates[]'),
            ),
          )
          .toList(),
      nextCursor: JsonReader.readNullableString(json, 'nextCursor'),
    );
  }

  /// Candidate users returned in the current slice.
  final List<ChatUserSummaryModel> candidates;

  /// Opaque cursor to request the next slice, when available.
  final String? nextCursor;
}
