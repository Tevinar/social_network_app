import 'package:bloc_app/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double? size;

  const Loader({super.key, this.size});

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
