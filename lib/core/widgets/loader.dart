import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

/// A loader widget.
class Loader extends StatelessWidget {
  /// Creates a [Loader].
  const Loader({super.key, this.size});

  /// The double.
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: AppPallete.whiteColor,
        constraints: size != null
            ? BoxConstraints(minWidth: size!, minHeight: size!)
            : null,
      ),
    );
  }
}
