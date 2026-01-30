import 'package:bloc_app/core/common/presentation/widgets/loader.dart';
import 'package:bloc_app/features/chat/presentation/blocs/user/user_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewChatPage extends StatelessWidget {
  const NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: BlocBuilder<UserListBloc, UserListState>(
        builder: (context, state) {
          if (state.fetchUsersState == RequestState.loading) {
            //Loading state
            return Loader();
          } else if (state.fetchUsersState == RequestState.error) {
            //error state
            return const Text(('Error loading users'));
          } else {
            //Success state
            return ListView.builder(
              itemCount: state.users.length + 1,
              itemBuilder: (context, index) {
                if (index == state.users.length) {
                  //Fetch new items
                  context.read<UserListBloc>().add(
                    ByPageGetUsers(nextPage: null),
                  );
                  return Container(height: 30, width: 30, color: Colors.red);
                } else {
                  //Show item card
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(state.users[index].name),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
