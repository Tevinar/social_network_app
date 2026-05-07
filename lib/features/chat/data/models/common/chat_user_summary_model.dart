import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/chat/domain/entities/chat_user_summary.dart';

/// Data-layer representation of one public chat user summary.
class ChatUserSummaryModel {
  /// Creates a [ChatUserSummaryModel].
  const ChatUserSummaryModel({
    required this.id,
    required this.name,
  });

  /// Builds a [ChatUserSummaryModel] from a backend JSON payload.
  factory ChatUserSummaryModel.fromJson(Map<String, dynamic> json) {
    return ChatUserSummaryModel(
      id: JsonReader.readString(json, 'id'),
      name: JsonReader.readString(json, 'name'),
    );
  }

  /// Stable user identifier.
  final String id;

  /// Public display name.
  final String name;

  /// Converts the model to the domain [ChatUserSummary] entity.
  ChatUserSummary toEntity() {
    return ChatUserSummary(
      id: id,
      name: name,
    );
  }
}
