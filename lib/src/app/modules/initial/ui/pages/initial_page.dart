import 'package:flutter/cupertino.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    return AppContainer(
      child: Center(
        child: Text('Initial Page'),
      ),
    );
  }
}
