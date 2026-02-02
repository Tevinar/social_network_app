import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class UserCheckboxPlaceholder extends StatelessWidget {
  const UserCheckboxPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Avatar placeholder
          const CircleAvatar(radius: 20, backgroundColor: AppPallete.greyColor),

          const SizedBox(width: 16),

          // Name placeholder
          Container(
            height: 14,
            width: 100,
            decoration: BoxDecoration(
              color: AppPallete.greyColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(width: 16),

          // Checkbox placeholder
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppPallete.greyColor, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}
