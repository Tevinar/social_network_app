part of '../routes.dart';

@TypedGoRoute<NewChatPageRoute>(path: '/new-chat')
/// A route for new chat page.
class NewChatPageRoute extends GoRouteData with $NewChatPageRoute {
  /// Creates a [NewChatPageRoute].
  const NewChatPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NewChatPage();
}

@TypedGoRoute<ChatMessagesPageRoute>(path: '/chat-messages')
/// A route for chat messages page.
class ChatMessagesPageRoute extends GoRouteData with $ChatMessagesPageRoute {
  /// Creates a [ChatMessagesPageRoute].
  const ChatMessagesPageRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChatMessagesPage();
}
