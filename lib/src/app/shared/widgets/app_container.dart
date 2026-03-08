import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  const AppContainer({required this.child, this.floatingActionButton, super.key});

  final Widget child;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.064,
          horizontal: size.width * 0.072,
        ),
        child: child,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
