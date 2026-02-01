part of '../routes.dart';

@TypedGoRoute<SignInPageRoute>(path: '/sign-in')
class SignInPageRoute extends GoRouteData with $SignInPageRoute {
  const SignInPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignInPage();
}

@TypedGoRoute<SignUpPageRoute>(path: '/sign-up')
class SignUpPageRoute extends GoRouteData with $SignUpPageRoute {
  const SignUpPageRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpPage();
}
