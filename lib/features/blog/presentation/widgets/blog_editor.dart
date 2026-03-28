import 'package:flutter/material.dart';

/// A blog editor.
class BlogEditor extends StatelessWidget {
  /// Creates a [BlogEditor].
  const BlogEditor({
    required this.controller,
    required this.hintText,
    super.key,
  });

  /// The controller.
  final TextEditingController controller;

  /// The hint text.
  final String hintText;

  @override
  /// The build.
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      maxLines: null,
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing';
        }
        return null;
      },
    );
  }
}
