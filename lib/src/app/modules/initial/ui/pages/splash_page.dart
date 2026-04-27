import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/modules/initial/ui/mixins/splash_page_mixin.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageConsumerState();
}

class _SplashPageConsumerState extends ConsumerState<SplashPage> with SingleTickerProviderStateMixin, SplashPageMixin<SplashPage> {
  @override
  void initState() {
    super.initState();
    setupAnimation(this);
    initializeApp();
  }

  @override
  Widget build(BuildContext context) => splashPageBody();
}
