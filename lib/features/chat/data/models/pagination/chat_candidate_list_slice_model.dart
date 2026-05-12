import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/data/models/common/chat_user_summary_model.dart';
import 'package:social_app/features/chat/domain/pagination/chat_candidate_list_slice.dart';

/// Data-layer representation of one cursor-based chat-candidate list slice.
class ChatCandidateListSliceModel {
  /// Creates a [ChatCandidateListSliceModel].
  const ChatCandidateListSliceModel({
    required this.candidates,
    required this.nextCursor,
  });

  /// Builds a [ChatCandidateListSliceModel] from a backend JSON payload.
  factory ChatCandidateListSliceModel.fromJson(Map<String, dynamic> json) {
    final candidates = JsonReader.readList(json, 'candidates');

    return ChatCandidateListSliceModel(
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

  /// Converts the model to the domain [ChatCandidateListSlice] entity.
  ChatCandidateListSlice toSlice() {
    return ChatCandidateListSlice(
      candidates: candidates.map((candidate) => candidate.toEntity()).toList(),
      nextCursor: nextCursor,
    );
  }
}
