import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/app/router/routes/routes.dart';
import 'package:social_app/app/session/app_user_cubit.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/widgets/loader.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';
import 'package:social_app/features/chat/presentation/blocs/chat_editor/'
    'chat_editor_bloc.dart';
import 'package:social_app/features/chat/presentation/blocs/user/'
    'users_bloc.dart';

/// A new chat page widget.
class NewChatPage extends StatefulWidget {
  /// Creates a [NewChatPage].
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final List<User> _selectedUsers = [];
  late final User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = (context.read<AppUserCubit>().state as AppUserSignedIn).user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: _buildBody,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody(BuildContext context, UsersState state) {
    if (state is UsersFailure) {
      return Center(
        child: Text('Error loading users : ${state.error}'),
      );
    }

    // Show placeholders while the first page of users is loading.
    if (state is UsersLoading && state.users.isEmpty) {
      return const Loader();
    }

    return _buildUsersList(context, state);
  }

  Widget _buildUsersList(BuildContext context, UsersState state) {
    return ListView.builder(
      controller: context.read<UsersBloc>().scrollController,
      itemCount: _userItemCount(state),
      itemBuilder: (context, index) => _buildUserListItem(state, index),
    );
  }

  Widget _buildUserListItem(UsersState state, int index) {
    if (index == state.users.length) {
      return const Loader(size: 30);
    }

    final user = state.users[index];

    if (_isCurrentUser(user)) {
      return const SizedBox.shrink();
    }

    return _buildUserSelectionTile(user);
  }

  bool _isCurrentUser(User user) {
    return user.id == _currentUser.id;
  }

  Widget _buildUserSelectionTile(User user) {
    return CheckboxListTile(
      secondary: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user.name),
      checkboxShape: const CircleBorder(),
      checkboxScaleFactor: 1.35,
      side: const BorderSide(
        width: 0.5,
        color: AppPallete.greyColor,
      ),
      checkColor: AppPallete.whiteColor,
      activeColor: AppPallete.gradient1,
      value: _selectedUsers.contains(user),
      onChanged: (value) => _toggleUserSelection(user, value),
    );
  }

  void _toggleUserSelection(User user, bool? value) {
    setState(() {
      if (value == true) {
        _selectedUsers.add(user);
      } else {
        _selectedUsers.remove(user);
      }
    });
  }

  int _userItemCount(UsersState state) {
    return state.users.length == state.totalUsersInDatabase
        ? state.users.length
        : state.users.length + 1;
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedUsers.isEmpty) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BlocConsumer<ChatEditorBloc, ChatEditorState>(
        listener: _onChatEditorStateChanged,
        builder: _buildCreateChatButton,
      ),
    );
  }

  void _onChatEditorStateChanged(
    BuildContext context,
    ChatEditorState state,
  ) {
    if (state is ChatEditorWaitingForFirstMessage ||
        state is ChatEditorLoaded) {
      const ChatMessagesPageRoute().pushReplacement(context);
    }
  }

  Widget _buildCreateChatButton(BuildContext context, ChatEditorState state) {
    return TextButton.icon(
      onPressed: () => _startChat(context, state),
      label: _buildCreateChatButtonLabel(context, state),
      icon: _buildCreateChatButtonIcon(state),
      style: _createChatButtonStyle(),
    );
  }

  Widget _buildCreateChatButtonLabel(
    BuildContext context,
    ChatEditorState state,
  ) {
    if (state is ChatEditorLoading) {
      return const Loader(size: 25);
    }

    return Text(
      'Message',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget? _buildCreateChatButtonIcon(ChatEditorState state) {
    if (state is ChatEditorLoading) {
      return null;
    }

    return const Icon(Icons.send, color: AppPallete.whiteColor);
  }

  ButtonStyle _createChatButtonStyle() {
    return ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(
        AppPallete.gradient1,
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      fixedSize: const WidgetStatePropertyAll(Size(140, 50)),
    );
  }

  void _startChat(BuildContext context, ChatEditorState state) {
    if (state is ChatEditorLoading) {
      return;
    }

    context.read<ChatEditorBloc>().add(
      AddChat(chatMembers: _chatMembersForCreation()),
    );
  }

  List<User> _chatMembersForCreation() {
    return [
      ..._selectedUsers,
      _currentUser,
    ];
  }
}
