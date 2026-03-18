import 'package:social_app/app/router/app.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:social_app/features/blog/presentation/blocs/blog_editor/blog_editor_bloc.dart';
import 'package:social_app/app/bootstrap/dependencies/init_dependencies.dart';
import 'package:social_app/features/blog/presentation/blocs/blogs/blogs_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_messages/chat_messages_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/chats/chats_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/user/users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (context) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (context) => serviceLocator<BlogEditorBloc>()),
        BlocProvider(create: (context) => serviceLocator<BlogsBloc>()),
        BlocProvider(create: (context) => serviceLocator<ChatEditorBloc>()),
        BlocProvider(create: (context) => serviceLocator<UsersBloc>()),
        BlocProvider(create: (context) => serviceLocator<ChatsBloc>()),
        BlocProvider(create: (context) => serviceLocator<ChatMessagesBloc>()),
      ],
      child: const SocialApp(),
    ),
  );
}
