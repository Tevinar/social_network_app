/// Domain entity representing one public chat user summary.
class ChatUserSummary {
  /// Creates a [ChatUserSummary].
  const ChatUserSummary({
    required this.id,
    required this.name,
  });

  /// Stable user identifier.
  final String id;

  /// Public display name.
  final String name;
}
