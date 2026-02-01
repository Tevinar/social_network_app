part of 'routes.dart';

@TypedGoRoute<InitialLoadingPageRoute>(path: '/initial-loading')
class InitialLoadingPageRoute extends GoRouteData
    with $InitialLoadingPageRoute {
  const InitialLoadingPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const InitialLoadingPage();
}
