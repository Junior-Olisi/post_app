import 'package:flutter/material.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post app',
      home: Scaffold(
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
