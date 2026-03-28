import 'package:flutter/material.dart';
import 'package:social_app/core/theme/app_pallete.dart';

class Loader extends StatelessWidget {
  const Loader({super.key, this.size});
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
