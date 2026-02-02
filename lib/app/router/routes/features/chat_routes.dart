part of '../routes.dart';

@TypedGoRoute<NewChatPageRoute>(path: '/new-chat')
class NewChatPageRoute extends GoRouteData with $NewChatPageRoute {
  const NewChatPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NewChatPage();
}

@TypedGoRoute<ChatMessagesPageRoute>(path: '/chat-messages')
class ChatMessagesPageRoute extends GoRouteData with $ChatMessagesPageRoute {
  const ChatMessagesPageRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ChatMessagesPage();
}
