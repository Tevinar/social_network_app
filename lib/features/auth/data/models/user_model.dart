import 'package:social_app/features/auth/domain/entities/user.dart';

/// Data model used to serialize user payloads from auth and profile sources.
class UserModel {
  /// Creates a [UserModel].
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  /// Creates a [UserModel] from a profile row payload.
  factory UserModel.fromProfileJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: '', // profiles table doesn’t own email
    );
  }

  /// Creates a [UserModel] from a domain [User].
  factory UserModel.fromEntity(User user) {
    return UserModel(id: user.id, name: user.name, email: user.email);
  }

  /// Creates a [UserModel] from an auth payload.
  factory UserModel.fromAuthJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name:
          (map['user_metadata'] as Map<String, dynamic>?)?['name'] as String? ??
          '',
    );
  }

  /// Unique user identifier.
  final String id;

  /// Display name.
  final String name;

  /// Email address when available.
  final String email;

  /// Converts the model to a serializable JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'email': email};
  }

  /// Returns a copy with the provided fields replaced.
  UserModel copyWith({String? id, String? name, String? email}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  /// Converts the model to the domain [User] entity.
  User toEntity() {
    return User(id: id, name: name, email: email);
  }
}
