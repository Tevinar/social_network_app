/// Defines chat fields.
abstract final class ChatFields {
  /// The id.
  static const String id = 'id';

  /// The last message id.
  static const String lastMessageId = 'last_message_id';

  /// The last message at.
  static const String lastMessageAt = 'last_message_at';
}

/// A chat foreign keys.
abstract final class ChatForeignKeys {
  /// The last message fkey.
  static const String lastMessageFkey = 'chats_last_message_fkey';
}
