import 'package:flutter/material.dart';
import 'package:post_app/src/app/modules/initial/ui/mixins/splash_page_mixin.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin, SplashPageMixin<SplashPage> {
  @override
  void initState() {
    super.initState();
    setupAnimation(this);
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return splashPageBody();
  }
}
