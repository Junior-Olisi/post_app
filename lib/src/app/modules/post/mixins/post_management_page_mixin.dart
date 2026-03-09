import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/validators/post/new_post_validator.dart';
import 'package:post_app/src/app/domain/validators/post/update_post_validator.dart';
import 'package:post_app/src/app/modules/post/pages/post_management_page.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:result_command/result_command.dart';

mixin PostManagementPageMixin<T extends StatefulWidget> on State<PostManagementPage> {
  final newPostValidator = NewPostValidator();
  final updatePostValidator = UpdatePostValidator();
  final newPostDto = NewPostDto.empty();
  final updatePostDto = UpdatePostDto.empty();

  @override
  void initState() {
    super.initState();
    widget.postViewModel.createPostCommand.addListener(createPostListenable);
    widget.postViewModel.updatePostCommand.addListener(updatePostListenable);
  }

  createPostListenable() async {
    final result = widget.postViewModel.createPostCommand.value;

    if (result is FailureCommand<Post>) {
      final error = result.error as PostError;
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<Post>) {
      final post = result.value;
      widget.postViewModel.userPostsList.value.insert(0, post);

      Modular.to.pushReplacementNamed(PostModuleRoutes.POST_PAGE, arguments: post);
    }
  }

  updatePostListenable() async {
    final result = widget.postViewModel.updatePostCommand.value;

    if (result is FailureCommand<Post>) {
      final error = result.error as PostError;
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<Post>) {
      final post = result.value;
      List<Post> postsList = [];
      postsList.addAll(widget.postViewModel.userPostsList.value);
      final updatedPost = postsList.where((post) => post.id == result.value.id).first;
      final updatedPostIndex = postsList.indexOf(updatedPost);
      postsList.removeWhere((post) => post.id == updatedPost.id);
      postsList.insert(updatedPostIndex, result.value);

      widget.postViewModel.userPostsList.value = postsList;

      Modular.to.pushReplacementNamed(PostModuleRoutes.POST_PAGE, arguments: post);
    }
  }

  @override
  void dispose() {
    widget.postViewModel.createPostCommand.removeListener(createPostListenable);
    widget.postViewModel.updatePostCommand.removeListener(updatePostListenable);
    super.dispose();
  }
}
