part of 'chat_editor_bloc.dart';

@immutable
sealed class ChatEditorState {
  final List<User> chatMembers;
  const ChatEditorState({required this.chatMembers});

  ChatEditorState copyWith({List<User>? chatMembers}) {
    return switch (this) {
      ChatEditorInitial() => ChatEditorInitial(
        chatMembers: chatMembers ?? this.chatMembers,
      ),

      ChatEditorLoading() => ChatEditorLoading(
        chatMembers: chatMembers ?? this.chatMembers,
      ),

      ChatEditorWaitingForFirstMessage() => ChatEditorWaitingForFirstMessage(
        chatMembers: chatMembers ?? this.chatMembers,
      ),

      ChatEditorSuccess() => ChatEditorSuccess(
        chatMembers: chatMembers ?? this.chatMembers,
      ),

      ChatEditorFailure(:final message) => ChatEditorFailure(
        message,
        chatMembers: chatMembers ?? this.chatMembers,
      ),
    };
  }
}

final class ChatEditorInitial extends ChatEditorState {
  const ChatEditorInitial({required super.chatMembers});
}

final class ChatEditorLoading extends ChatEditorState {
  const ChatEditorLoading({required super.chatMembers});
}

final class ChatEditorWaitingForFirstMessage extends ChatEditorState {
  const ChatEditorWaitingForFirstMessage({required super.chatMembers});
}

final class ChatEditorSuccess extends ChatEditorState {
  const ChatEditorSuccess({required super.chatMembers});
}

final class ChatEditorFailure extends ChatEditorState {
  final String message;
  const ChatEditorFailure(this.message, {required super.chatMembers});
}
