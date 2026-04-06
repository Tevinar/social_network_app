import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/bootstrap/configure_global_error_handling.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/app/logging/app_bloc_observer.dart';
import 'package:social_app/app/logging/app_talker_logger.dart';
import 'package:social_app/app/logging/talker_config.dart';
import 'package:social_app/app/router/app.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_editor/'
    'blog_editor_bloc.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/'
    'blogs_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/'
    'chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chats/'
    'chats_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/user/'
    'users_bloc.dart';

void main() async {
  // Local logger available immediately during app startup, before GetIt and the
  // DI-backed `appLogger` are registered. This ensures bootstrap failures can
  // still be logged safely.
  final AppLogger bootstrapLogger = AppTalkerLogger(talker: createTalker());

  // Final Dart-zone safety net for uncaught async errors
  // during startup and app execution.
  await (runZonedGuarded<Future<void>>(
        () async {
          WidgetsFlutterBinding.ensureInitialized();

          configureGlobalErrorHandling(bootstrapLogger);

          await initDependencies();

          // Switch to the DI-backed logger after bootstrap.
          Bloc.observer = AppBlocObserver(logger: appLogger);

          runApp(
            MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
                BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
                BlocProvider(create: (_) => serviceLocator<BlogEditorBloc>()),
                BlocProvider(create: (_) => serviceLocator<ChatEditorBloc>()),
                BlocProvider(create: (_) => serviceLocator<UsersBloc>()),
                BlocProvider(create: (_) => serviceLocator<ChatsBloc>()),
              ],
              child: const SocialApp(),
            ),
          );
        },
        (error, stackTrace) {
          bootstrapLogger.error(
            'Unhandled zoned error',
            error: error,
            stackTrace: stackTrace,
          );
        },
        // `runZonedGuarded` returns a nullable value. If the body fails before
        // producing `Future<void>`, fall back to a completed future so `await`
        // always receives a non-null future.
      ) ??
      Future<void>.value());
}
