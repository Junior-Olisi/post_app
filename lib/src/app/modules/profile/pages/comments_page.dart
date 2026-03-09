import 'package:flutter/material.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/profile/mixins/comments_page_mixin.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({
    required this.user,
    required this.postViewModel,
    super.key,
  });

  final User user;
  final PostViewModel postViewModel;

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> with CommentsPageMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AppContainer(
      child: AnimatedBuilder(
        animation: widget.postViewModel.getUserCommentsCommand,
        builder: (_, __) {
          return ListView(
            children: [
              UserTile(
                user: widget.user,
                onTap: null,
                tileType: UserTileType.large,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.024,
                ),
                child: Text(
                  'Comentários',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              ...widget.postViewModel.userCommentsList.value.map((comment) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    widget.user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    comment.body,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
