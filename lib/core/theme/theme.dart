import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

class AppTheme {
  static OutlineInputBorder _border([Color color = AppPallete.borderColor]) =>
      OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 3),
        borderRadius: BorderRadius.circular(10),
      );

  static final ThemeData darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    chipTheme: const ChipThemeData(
      color: WidgetStatePropertyAll(AppPallete.backgroundColor),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(),

      border: _border(),
      focusedBorder: _border(AppPallete.gradient2),
      errorBorder: _border(AppPallete.errorColor),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
      surfaceTintColor: AppPallete.backgroundColor,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: AppPallete.backgroundColor,
    ),
    textTheme: const TextTheme().copyWith(
      titleMedium: const TextStyle(overflow: TextOverflow.ellipsis),
    ),
  );
}
