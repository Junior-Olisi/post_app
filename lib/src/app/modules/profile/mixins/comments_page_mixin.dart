import 'package:flutter/material.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/domain/entities/post/comment.dart';
import 'package:post_app/src/app/modules/profile/pages/comments_page.dart';
import 'package:result_command/result_command.dart';

mixin CommentsPageMixin<T extends StatefulWidget> on State<CommentsPage> {
  @override
  void initState() {
    super.initState();
    widget.postViewModel.getUserCommentsCommand.addListener(getUserCommentsListenable);
    widget.postViewModel.getUserCommentsCommand.execute(widget.user);
  }

  getUserCommentsListenable() {
    final result = widget.postViewModel.getUserCommentsCommand.value;

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
      widget.postViewModel.userCommentsList.value = result.value;
    }
  }

  @override
  void dispose() {
    widget.postViewModel.getUserCommentsCommand.removeListener(getUserCommentsListenable);
    super.dispose();
  }
}
