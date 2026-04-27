import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class PostPage extends ConsumerStatefulWidget {
  const PostPage({required this.post, super.key});

  final Post post;

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  late Post post;

  @override
  void initState() {
    super.initState();
    post = widget.post;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(postStateProvider.notifier).getPostComments(post);
    });
  }

  Future<void> _showPostDeletionDialog() async {
    final size = MediaQuery.sizeOf(context);

    await showDialog(
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
              final deletedId = await ref.read(postStateProvider.notifier).deletePost(post);
              if (deletedId != null && mounted) {
                Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
              }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.032;
    final userState = ref.watch(userStateProvider);
    final postState = ref.watch(postStateProvider);
    final currentUser = userState.currentUser;

    if (postState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            content: Text(postState.errorMessage!),
          ),
        );
        ref.read(postStateProvider.notifier).clearError();
      });
    }

    if (currentUser == null) {
      return AppContainer(
        child: Center(
          child: Text(
            'Nenhum usuário selecionado.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return AppContainer(
      child: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          UserTile(
            user: currentUser,
            onTap: null,
            tileType: UserTileType.large,
          ),
          SizedBox(height: size.height * 0.036),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
              if (currentUser.userType == UserType.primary)
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
                          arguments: post,
                        );
                      },
                    ),
                    PopupMenuItem(
                      onTap: _showPostDeletionDialog,
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
                  post.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (currentUser.userType == UserType.primary)
                IconButton(
                  onPressed: () async {
                    final likedPost = await ref.read(postStateProvider.notifier).likePost(post);
                    if (likedPost != null && mounted) {
                      setState(() {
                        post = likedPost;
                      });
                    }
                  },
                  icon: post.hasUserLike
                      ? Icon(
                          FluentIcons.heart_12_filled,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(FluentIcons.heart_12_regular),
                ),
            ],
          ),
          SizedBox(height: size.height * 0.036),
          if (postState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comentários ${postState.postComments.length}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                ...postState.postComments.map((comment) {
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
            ),
        ],
      ),
    );
  }
}
