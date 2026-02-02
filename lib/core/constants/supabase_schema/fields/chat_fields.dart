abstract final class ChatFields {
  static const String id = 'id';
  static const String lastMessageId = 'last_message_id';
  static const String lastMessageAt = 'last_message_at';
}

abstract final class ChatForeignKeys {
  static const String lastMessageFkey = 'chats_last_message_fkey';
}
