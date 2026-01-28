import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double? size;

  const Loader({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        constraints: size != null
            ? BoxConstraints(minWidth: size!, minHeight: size!)
            : null,
      ),
    );
  }
}
