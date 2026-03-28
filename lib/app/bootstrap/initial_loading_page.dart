import 'package:flutter/material.dart';

/// A initial loading page widget.
class InitialLoadingPage extends StatelessWidget {
  /// Creates a [InitialLoadingPage].
  const InitialLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/flutter_logo.png',
        height: 150,
        width: 150,
      ),
    );
  }
}
