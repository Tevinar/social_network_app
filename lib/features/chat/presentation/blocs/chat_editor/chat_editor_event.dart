part of 'chat_editor_bloc.dart';

@immutable
/// Base type for all chat editor events.
sealed class ChatEditorEvent {}

/// Requests loading or creating a chat for the selected members.
class AddChat extends ChatEditorEvent {
  /// Creates an [AddChat].
  AddChat({required this.chatMembers});

  /// Members selected for the chat.
  final List<User> chatMembers;
}

/// Requests creation of the first message for a newly drafted chat.
class AddChatFirstMessage extends ChatEditorEvent {
  /// Creates an [AddChatFirstMessage].
  AddChatFirstMessage({required this.firstMessageContent});

  /// Content of the first message to send.
  final String firstMessageContent;
}

/// Selects an existing chat and loads it into the editor state.
class SelectChat extends ChatEditorEvent {
  /// Creates a [SelectChat].
  SelectChat({required this.chatId, required this.chatMembers});

  /// Identifier of the selected chat.
  final String chatId;

  /// Members belonging to the selected chat.
  final List<User> chatMembers;
}
