import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  const AppContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.048,
          horizontal: size.width * 0.024,
        ),
        child: child,
      ),
    );
  }
}
