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
    final logoImage = Theme.of(context).brightness == Brightness.light ? 'assets/logo/light_logo.png' : 'assets/logo/dark_logo.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  logoImage,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
