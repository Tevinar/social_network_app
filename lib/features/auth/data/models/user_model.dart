// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_app/features/auth/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  UserModel({required this.id, required this.name, required this.email});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'name': name, 'email': email};
  }

  /// UserModel.fromJson factory constructor initializes a final variable from a JSON object.
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(id: user.id, name: user.name, email: user.email);
  }

  UserModel copyWith({String? id, String? name, String? email}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  User toEntity() {
    return User(id: id, name: name, email: email);
  }
}
