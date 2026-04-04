import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/chat/presentation/blocs/chats/'
    'chats_bloc.dart';
import 'package:social_app/features/chat/presentation/widgets/chat_card.dart';

/// A chats page widget.
class ChatsPage extends StatelessWidget {
  /// Creates a [ChatsPage].
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ChatsBloc, ChatsState>(
          builder: _buildBody,
        ),
      ),
      floatingActionButton: _buildNewChatButton(context),
    );
  }

  Widget _buildBody(BuildContext context, ChatsState state) {
    if (state is ChatsFailure) {
      return Center(
        child: Text('Error loading chats : ${state.error}'),
      );
    }

    // Show placeholders while the first page of chats is loading.
    if (state is ChatsLoading && state.chats.isEmpty) {
      return const Center(child: Loader());
    }

    if (state.chats.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildChatsList(context, state);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        "You don't have any chats. Start a new one!",
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildChatsList(BuildContext context, ChatsState state) {
    return ListView.builder(
      controller: context.read<ChatsBloc>().scrollController,
      itemCount: _chatItemCount(state),
      itemBuilder: (context, index) => _buildChatListItem(state, index),
    );
  }

  Widget _buildChatListItem(ChatsState state, int index) {
    if (index == state.chats.length) {
      return const Loader(size: 30);
    }

    return ChatCard(chat: state.chats[index]);
  }

  int _chatItemCount(ChatsState state) {
    return state.chats.length == state.totalChatsInDatabase
        ? state.chats.length
        : state.chats.length + 1;
  }

  Widget _buildNewChatButton(BuildContext context) {
    return IconButton(
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
      onPressed: () => const NewChatPageRoute().push<void>(context),
      icon: const Icon(Icons.add_box_rounded, size: 25),
    );
  }
}
