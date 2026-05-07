import 'package:social_app/core/serialization/json_reader.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

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

  /// Converts the model to the auth/domain [User] entity.
  ///
  /// The chat backend does not expose emails in these payloads, so the field is
  /// mapped to an empty string for now.
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: '',
    );
  }
}
