import 'package:bloc_app/core/common/presentation/widgets/loader.dart';
import 'package:bloc_app/features/chat/presentation/blocs/user/users_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewChatPage extends StatelessWidget {
  const NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersFailure) {
            return const Center(child: Text(('Error loading users')));
          }
          // Show loading placeholders when users are being fetched for the first time
          else if (state is UsersLoading && state.users.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: List.generate(
                  4,
                  (index) => Text(' Loading user...'),
                ), // TODO Replace with proper placeholder
              ),
            );
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
                  return Text(
                    state.users[index].name,
                  ); // TODO Replace with proper user card
                }
              },
            );
          }
        },
      ),
    );
  }
}
