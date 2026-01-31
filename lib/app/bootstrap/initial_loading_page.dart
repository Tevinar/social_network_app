import 'package:flutter/material.dart';

class InitialLoadingPage extends StatelessWidget {
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
