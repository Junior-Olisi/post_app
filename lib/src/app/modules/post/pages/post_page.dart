import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/post/mixins/post_page_mixin.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class PostPage extends StatefulWidget {
  PostPage({
    required this.userViewModel,
    required this.postViewModel,
    required this.post,
    super.key,
  });

  final UserViewModel userViewModel;
  final PostViewModel postViewModel;
  Post post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> with PostPageMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.032;

    return AppContainer(
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          UserTile(
            user: widget.userViewModel.currentUser,
            onTap: null,
            tileType: UserTileType.large,
          ),
          SizedBox(height: size.height * 0.036),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.post.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.list_sharp),
                menuPadding: EdgeInsets.symmetric(horizontal: size.width * 0.036),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    child: Text(
                      'Editar',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: () async {
                      Modular.to.pushReplacementNamed(
                        '${PostModuleRoutes.POST_MANAGEMENT_PAGE}/?mode=update',
                        arguments: widget.post,
                      );
                    },
                  ),
                  PopupMenuItem(
                    onTap: showPostDeletionDialog,
                    child: Text(
                      'Excluir',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  widget.post.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              AnimatedBuilder(
                animation: widget.postViewModel.likePostCommand,
                builder: (_, __) {
                  return IconButton(
                    onPressed: () async {
                      await widget.postViewModel.likePostCommand.execute(widget.post);
                    },
                    icon: widget.post.hasUserLike
                        ? Icon(
                            FluentIcons.heart_12_filled,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : Icon(
                            FluentIcons.heart_12_regular,
                          ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: size.height * 0.036),
          AnimatedBuilder(
            animation: widget.postViewModel.getPostCommentsCommand,
            builder: (_, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comentários ${widget.postViewModel.postCommentsList.value.length}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  ...widget.postViewModel.postCommentsList.value.map((comment) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        spacing: spacing / 4,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            comment.email,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      subtitle: Text(comment.body),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
