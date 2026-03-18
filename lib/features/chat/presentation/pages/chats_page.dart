import 'package:social_network_app/core/widgets/loader.dart';
import 'package:social_network_app/core/theme/app_pallete.dart';
import 'package:social_network_app/features/chat/presentation/blocs/chats/chats_bloc.dart';
import 'package:social_network_app/features/chat/presentation/widgets/chat_card.dart';
import 'package:social_network_app/app/router/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<ChatsBloc, ChatsState>(
          builder: (context, state) {
            if (state is ChatsFailure) {
              return Center(
                child: Text(('Error loading chats : ${state.error}')),
              );
            }
            // Show loading placeholders when chats are being fetched for the first time
            else if (state is ChatsLoading && state.chats.isEmpty) {
              return const Center(child: Loader());
            } else {
              if (state.chats.isEmpty) {
                return Center(
                  child: Text(
                    'You don\'t have any chats. Start a new one!',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }

              return ListView.builder(
                controller: context.read<ChatsBloc>().scrollController,
                itemCount: state.chats.length == state.totalChatsInDatabase
                    ? state.chats.length
                    : state.chats.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.chats.length) {
                    return const Loader(size: 30);
                  } else {
                    return ChatCard(chat: state.chats[index]);
                  }
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: IconButton(
        color: AppPallete.whiteColor,
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsetsGeometry.all(12)),
          backgroundColor: const WidgetStatePropertyAll(AppPallete.gradient1),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(10),
            ),
          ),
        ),
        onPressed: () => const NewChatPageRoute().push(context),
        icon: const Icon(Icons.add_box_rounded, size: 25),
      ),
    );
  }
}
