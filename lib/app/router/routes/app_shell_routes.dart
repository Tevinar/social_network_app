part of 'routes.dart';

/// A route for blog page.
class BlogPageRoute extends GoRouteData with $BlogPageRoute {
  /// Creates a [BlogPageRoute].
  const BlogPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const BlogsPage();
}

/// A route for chats page.
class ChatsPageRoute extends GoRouteData with $ChatsPageRoute {
  /// Creates a [ChatsPageRoute].
  const ChatsPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ChatsPage();
}

@TypedStatefulShellRoute<AppShellRouteData>(
  branches: <TypedStatefulShellBranch<StatefulShellBranchData>>[
    // Blogs Tab
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[TypedGoRoute<BlogPageRoute>(path: '/')],
    ),
    // Chats Tab
    TypedStatefulShellBranch(
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<ChatsPageRoute>(path: '/chats'),
      ],
    ),
  ],
)
/// A route for app shell data.
class AppShellRouteData extends StatefulShellRouteData {
  /// Creates a [AppShellRouteData].
  const AppShellRouteData();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
  // Return the widget that implements the custom shell (in this case
  // using a BottomNavigationBar). The StatefulNavigationShell is passed
  // to be able access the state of the shell and to navigate to other
  // branches in a stateful way.
}
