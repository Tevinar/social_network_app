import 'package:bloc_app/features/chat/presentation/blocs/chat_editor/chat_editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({super.key});

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatEditorBloc, ChatEditorState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(state.chatMembers.join(', '))),
          body: Column(
            children: [
              if (state is ChatEditorSuccess)
                Flexible(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) =>
                        Container(color: Colors.amberAccent, height: 10),
                  ),
                )
              else
                const Expanded(child: SizedBox()),
              TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
