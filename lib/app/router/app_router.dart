import 'package:social_network_app/app/session/app_user_cubit.dart';
import 'package:social_network_app/core/utils/stream_to_listenable.dart';
import 'package:social_network_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_network_app/app/router/routes/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: const InitialLoadingPageRoute().location,
    routes: $appRoutes,

    // Changes on the listenable will cause the router to refresh it's route
    refreshListenable: StreamToListenable([
      serviceLocator<AppUserCubit>().stream,
    ]),

    //The top-level callback allows the app to redirect to a new location.
    redirect: (context, state) {
      final AppUserState appUserState = context.read<AppUserCubit>().state;

      // If signed out and not on sign in page, redirect to sign in
      if (appUserState is AppUserSignedOut &&
          (!state.matchedLocation.contains(const SignInPageRoute().location) &&
              !state.matchedLocation.contains(
                const SignUpPageRoute().location,
              ))) {
        return const SignInPageRoute().location;
      }

      // If signed in and trying to access root or sign in, redirect to blogPage
      if (appUserState is AppUserSignedIn &&
          (state.matchedLocation == const SignInPageRoute().location ||
              state.matchedLocation == const SignUpPageRoute().location ||
              state.matchedLocation ==
                  const InitialLoadingPageRoute().location)) {
        return const BlogPageRoute().location;
      }

      // Otherwise, allow navigation (including tabs)
      return null;
    },
  );
}
