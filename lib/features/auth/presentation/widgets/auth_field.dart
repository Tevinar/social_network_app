import 'package:flutter/material.dart';

/// A auth field widget.
class AuthField extends StatelessWidget {
  /// Creates a [AuthField].
  const AuthField({
    required this.hintText,
    required this.controller,
    super.key,
    this.isObscureText = false,
  });

  /// The hint text.
  final String hintText;

  /// The controller.
  final TextEditingController controller;

  /// Whether the value bool.
  final bool isObscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscureText,
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing!';
        }
        return null; //No error
      },
    );
  }
}
