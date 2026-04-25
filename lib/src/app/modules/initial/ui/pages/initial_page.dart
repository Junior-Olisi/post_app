import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/modules/initial/ui/mixins/initial_page_mixin.dart';

class InitialPage extends ConsumerStatefulWidget {
  const InitialPage({super.key});

  @override
  ConsumerState<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends ConsumerState<InitialPage> with InitialPageMixin {
  @override
  Widget build(BuildContext context) => initialPageBody();
}
