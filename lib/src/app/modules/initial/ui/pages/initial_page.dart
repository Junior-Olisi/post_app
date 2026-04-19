import 'package:flutter/material.dart';
import 'package:post_app/src/app/modules/initial/ui/mixins/initial_page_mixin.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with InitialPageMixin {
  @override
  Widget build(BuildContext context) {
    return initialPageBody();
  }
}
