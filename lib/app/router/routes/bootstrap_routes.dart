part of 'routes.dart';

@TypedGoRoute<InitialLoadingPageRoute>(path: '/initial-loading')
/// A route for initial loading page.
class InitialLoadingPageRoute extends GoRouteData
    with $InitialLoadingPageRoute {
  /// Creates a [InitialLoadingPageRoute].
  const InitialLoadingPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InitialLoadingPage();
}
