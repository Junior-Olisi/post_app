import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = ref.read(userStateProvider).currentUser;
      if (currentUser != null) {
        await ref.read(postStateProvider.notifier).getUserPosts(currentUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
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

    final isPrimaryUser = currentUser.userType == UserType.primary;

    return AppContainer(
      floatingActionButton: isPrimaryUser
          ? FloatingActionButton(
              onPressed: () {
                Modular.to.pushNamed('${PostModuleRoutes.POST_MANAGEMENT_PAGE}/?mode=create');
              },
              child: const Icon(Icons.add),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserTile(
            user: currentUser,
            onTap: () {
              Modular.to.pushNamed(ProfileModuleRoutes.PROFILE_PAGE, arguments: currentUser);
            },
            tileType: UserTileType.large,
          ),
          Padding(
            padding: EdgeInsets.only(top: size.height * 0.036),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meus Posts',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (isPrimaryUser)
                  PopupMenuButton(
                    icon: const Icon(Icons.filter_list),
                    menuPadding: EdgeInsets.symmetric(horizontal: size.width * 0.036),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text(
                          'Meus Posts',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () async {
                          await ref.read(postStateProvider.notifier).getUserPosts(currentUser);
                        },
                      ),
                      PopupMenuItem(
                        child: Text(
                          'Selecionar Usuário',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        onTap: () {
                          Modular.to.pushNamed(UserModuleRoutes.USER_SELECTION_PAGE);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (postState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (postState.userPosts.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'O usuário não possui nenhum post salvo',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: postState.userPosts.length,
                itemBuilder: (_, index) {
                  final post = postState.userPosts[index];

                  return ListTile(
                    title: UserTile(
                      user: currentUser,
                      onTap: null,
                      tileType: UserTileType.minimal,
                    ),
                    contentPadding: EdgeInsets.zero,
                    subtitle: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: () {
                      Modular.to.pushNamed(PostModuleRoutes.POST_PAGE, arguments: post);
                    },
                    trailing: isPrimaryUser
                        ? IconButton(
                            onPressed: () async {
                              await ref.read(postStateProvider.notifier).likePost(post);
                            },
                            icon: post.hasUserLike
                                ? Icon(
                                    FluentIcons.heart_12_filled,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : const Icon(FluentIcons.heart_12_regular),
                          )
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
