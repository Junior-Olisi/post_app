import 'package:flutter/material.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/user/mixins/home_page_mixin.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.userViewModel, required this.postViewModel, super.key});

  final UserViewModel userViewModel;
  final PostViewModel postViewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomePageMixin {
  @override
  Widget build(BuildContext context) => homePageBody();
}
