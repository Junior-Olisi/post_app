import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/domain/entities/post/comment.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/modules/post/pages/post_page.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:result_command/result_command.dart';

mixin PostPageMixin<T extends StatefulWidget> on State<PostPage> {
  @override
  void initState() {
    super.initState();

    widget.postViewModel.likePostCommand.addListener(likePostListenable);
    widget.postViewModel.deletePostCommand.addListener(deletePostListenable);
    widget.postViewModel.getPostCommentsCommand.addListener(getPostCommentsListenable);

    widget.postViewModel.getPostCommentsCommand.execute(widget.post);
  }

  showPostDeletionDialog() {
    final size = MediaQuery.sizeOf(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        buttonPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.048),
        titlePadding: EdgeInsets.symmetric(vertical: size.height * 0.02),
        actionsPadding: EdgeInsets.zero,
        actionsAlignment: MainAxisAlignment.center,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Remover Post',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: size.height * 0.14,
          width: size.width,
          child: Column(
            children: [
              Text(
                'Deseja remover o post da sua lista de posts preferidos? Você poderá adicioná-lo à lista novamente.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Modular.to.pop();
              await widget.postViewModel.deletePostCommand.execute(widget.post);
            },
            child: Text(
              'SIM',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Modular.to.pop();
            },
            child: Text(
              'NÃO',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
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
      widget.post = result.value;
    }
  }

  deletePostListenable() async {
    final result = widget.postViewModel.deletePostCommand.value;

    if (result is FailureCommand<int>) {
      final error = result.error as PostError;
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<int>) {
      List<Post> postsList = [];
      postsList.addAll(widget.postViewModel.userPostsList.value);
      final deletedPost = postsList.where((post) => post.id == result.value).first;
      postsList.removeWhere((post) => post.id == deletedPost.id);

      widget.postViewModel.userPostsList.value = postsList;

      Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
    }
  }

  getPostCommentsListenable() async {
    final result = widget.postViewModel.getPostCommentsCommand.value;

    if (result is FailureCommand<List<Comment>>) {
      final error = result.error as PostError;
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<List<Comment>>) {
      widget.postViewModel.postCommentsList.value = result.value;
    }
  }

  @override
  void dispose() {
    widget.postViewModel.likePostCommand.removeListener(likePostListenable);
    widget.postViewModel.deletePostCommand.removeListener(deletePostListenable);
    widget.postViewModel.getPostCommentsCommand.removeListener(getPostCommentsListenable);
    super.dispose();
  }
}
