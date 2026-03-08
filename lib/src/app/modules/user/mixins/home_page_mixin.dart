import 'package:flutter/material.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:post_app/src/app/modules/user/pages/home_page.dart';
import 'package:result_command/result_command.dart';

mixin HomePageMixin<T extends StatefulWidget> on State<HomePage> {
  @override
  void initState() {
    super.initState();
    final userId = widget.userViewModel.primaryUser.id;

    widget.postViewModel.getUserPostsCommand.addListener(getUserPostsListenable);
    widget.postViewModel.likePostCommand.addListener(likePostListenable);

    widget.postViewModel.getUserPostsCommand.execute(userId);
  }

  getUserPostsListenable() {
    final result = widget.postViewModel.getUserPostsCommand.value;

    if (result is FailureCommand<PostList>) {
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text('Erro ao obter posts do usuário'),
        ),
      );
    }

    if (result is SuccessCommand<PostList>) {
      widget.postViewModel.userPostsList.value = result.value.posts;
    }
  }

  likePostListenable() async {
    final result = widget.postViewModel.likePostCommand.value;

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
      List<Post> postsList = [];
      postsList.addAll(widget.postViewModel.userPostsList.value);
      final likedPost = postsList.where((post) => post.id == result.value.id).first;
      final likedPostIndex = postsList.indexOf(likedPost);
      postsList.removeWhere((post) => post.id == likedPost.id);
      postsList.insert(likedPostIndex, result.value);

      widget.postViewModel.userPostsList.value = postsList;
      widget.postViewModel.preferedPostsList.value.add(result.value);
    }
  }

  @override
  void dispose() {
    widget.postViewModel.getUserPostsCommand.removeListener(getUserPostsListenable);
    widget.postViewModel.likePostCommand.removeListener(likePostListenable);

    super.dispose();
  }
}
