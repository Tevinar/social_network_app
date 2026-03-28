import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/user/users_bloc.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  List<User> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersFailure) {
            return Center(
              child: Text('Error loading users : ${state.error}'),
            );
          }
          // Show loading placeholders when users are being fetched for the first time
          else if (state is UsersLoading && state.users.isEmpty) {
            return const Loader();
          } else {
            return ListView.builder(
              controller: context.read<UsersBloc>().scrollController,
              itemCount: state.users.length == state.totalUsersInDatabase
                  ? state.users.length
                  : state.users.length + 1,
              itemBuilder: (context, index) {
                if (index == state.users.length) {
                  return const Loader(size: 30);
                } else {
                  if (state.users[index].id ==
                      (context.read<AppUserCubit>().state as AppUserSignedIn)
                          .user
                          .id) {
                    return const SizedBox.shrink();
                  }
                  return CheckboxListTile(
                    secondary: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(state.users[index].name),
                    checkboxShape: const CircleBorder(),
                    checkboxScaleFactor: 1.35,
                    side: const BorderSide(
                      width: 0.5,
                      color: AppPallete.greyColor,
                    ),
                    checkColor: AppPallete.whiteColor,
                    activeColor: AppPallete.gradient1,
                    value: selectedUsers.contains(state.users[index]),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(state.users[index]);
                        } else {
                          selectedUsers.remove(state.users[index]);
                        }
                      });
                    },
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: selectedUsers.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: BlocConsumer<ChatEditorBloc, ChatEditorState>(
                listener: (context, state) {
                  if (state is ChatEditorWaitingForFirstMessage ||
                      state is ChatEditorLoaded) {
                    const ChatMessagesPageRoute().pushReplacement(context);
                  }
                },
                builder: (context, state) {
                  return TextButton.icon(
                    onPressed: () {
                      if (state is! ChatEditorLoading) {
                        final currentUser =
                            (context.read<AppUserCubit>().state
                                    as AppUserSignedIn)
                                .user;
                        selectedUsers.add(currentUser);
                        context.read<ChatEditorBloc>().add(
                          AddChat(chatMembers: selectedUsers),
                        );
                      }
                    },
                    label: state is ChatEditorLoading
                        ? const Loader(size: 25)
                        : Text(
                            'Message',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                    icon: state is ChatEditorLoading
                        ? null
                        : const Icon(Icons.send, color: AppPallete.whiteColor),

                    style: ButtonStyle(
                      backgroundColor: const WidgetStatePropertyAll(
                        AppPallete.gradient1,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                      fixedSize: const WidgetStatePropertyAll(Size(140, 50)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
