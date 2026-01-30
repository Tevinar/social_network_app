import 'package:bloc_app/core/common/domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.id, required super.name, required super.email});

  /// UserModel.fromJson factory constructor initializes a final variable from a JSON object.
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  UserModel copyWith({String? id, String? name, String? email}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
