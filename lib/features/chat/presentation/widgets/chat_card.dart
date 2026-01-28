import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: 20),
      child: Row(
        spacing: 10,
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Name Name Name Name Name Name Name Name Name ',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Text('08:15'),
                  ],
                ),

                Text(
                  'Last message Last message Last message Last message',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppPallete.greyColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
