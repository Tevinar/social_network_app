part of '../routes.dart';

@TypedGoRoute<NewChatPageRoute>(path: '/new-chat')
class NewChatPageRoute extends GoRouteData with $NewChatPageRoute {
  const NewChatPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const NewChatPage();
}
