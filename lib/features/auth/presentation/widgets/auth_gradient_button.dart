import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/core/theme/app_pallete.dart';
import 'package:social_app/core/ui/widgets/loader.dart';
import 'package:social_app/features/auth/presentation/bloc/auth_bloc.dart';

/// A auth gradient button widget.
class AuthGradientButton extends StatelessWidget {
  /// Creates a [AuthGradientButton].
  const AuthGradientButton({
    required this.buttonText,
    required this.onPressed,
    super.key,
  });

  /// The button text.
  final String buttonText;

  /// The on pressed.
  final VoidCallback onPressed;

  @override
  /// The build.
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPallete.gradient1, AppPallete.gradient2],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state is AuthLoading ? null : onPressed,

            style: ElevatedButton.styleFrom(
              fixedSize: const Size(395, 55),
              backgroundColor: AppPallete.transparentColor,
              shadowColor: AppPallete.transparentColor,
            ),
            child: state is AuthLoading
                ? const Loader(size: 20)
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
