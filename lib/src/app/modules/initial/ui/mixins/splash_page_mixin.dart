import 'package:flutter/material.dart';

mixin SplashPageMixin<T extends StatefulWidget> on State<T> {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  void setupAnimation(TickerProvider tickerProvider) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: tickerProvider,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();
  }

  Future<void> initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/user/home');
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
