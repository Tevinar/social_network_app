/// Domain entity representing an authenticated application user.
class User {
  /// Creates a [User].
  const User({required this.id, required this.name, required this.email});

  /// Unique user identifier.
  final String id;

  /// Display name shown in the UI.
  final String name;

  /// Email address associated with the account.
  final String email;

  /// Returns the user's display name.
  @override
  String toString() {
    return name;
  }
}
