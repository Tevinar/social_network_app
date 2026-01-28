import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:bloc_app/features/chat/presentation/widgets/chat_card.dart';
import 'package:bloc_app/routing/router_config.dart';
import 'package:flutter/material.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) => const ChatCard(),
        ),
      ),
      floatingActionButton: IconButton(
        color: AppPallete.backgroundColor,
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
