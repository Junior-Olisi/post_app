import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/user/mixins/home_page_mixin.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.userViewModel, required this.postViewModel, super.key});

  final UserViewModel userViewModel;
  final PostViewModel postViewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomePageMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AppContainer(
      floatingActionButton: widget.userViewModel.currentUser.userType == UserType.primary
          ? FloatingActionButton(
              onPressed: () {
                Modular.to.pushNamed('${PostModuleRoutes.POST_MANAGEMENT_PAGE}/?mode=create');
              },
              child: Icon(Icons.add),
            )
          : null,
      child: AnimatedBuilder(
        animation: widget.postViewModel.userPostsList,
        builder: (_, __) {
          return widget.postViewModel.userPostsList.value.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserTile(
                      user: widget.userViewModel.currentUser,
                      onTap: () {
                        Modular.to.pushNamed(ProfileModuleRoutes.PROFILE_PAGE, arguments: widget.userViewModel.currentUser);
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
                          if (widget.userViewModel.currentUser.userType == UserType.primary)
                            PopupMenuButton(
                              icon: Icon(Icons.filter_list),
                              menuPadding: EdgeInsets.symmetric(horizontal: size.width * 0.036),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  child: Text(
                                    'Meus Posts',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  onTap: () async {
                                    final user = widget.userViewModel.currentUser;

                                    await widget.postViewModel.getUserPostsCommand.execute(user);
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
                    AnimatedBuilder(
                      animation: widget.postViewModel.userPostsList,
                      builder: (_, __) {
                        final widgetLoadingState = widget.postViewModel.getUserPostsCommand.value.isRunning;

                        return widgetLoadingState
                            ? Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.postViewModel.userPostsList.value.length,
                                  itemBuilder: (_, i) {
                                    final post = widget.postViewModel.userPostsList.value[i];

                                    return ListTile(
                                      title: UserTile(
                                        user: widget.userViewModel.currentUser,
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
                                      trailing: widget.userViewModel.currentUser.userType == UserType.primary
                                          ? IconButton(
                                              onPressed: () async {
                                                await widget.postViewModel.likePostCommand.execute(post);
                                              },
                                              icon: post.hasUserLike
                                                  ? Icon(
                                                      FluentIcons.heart_12_filled,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    )
                                                  : Icon(
                                                      FluentIcons.heart_12_regular,
                                                    ),
                                            )
                                          : null,
                                    );
                                  },
                                ),
                              );
                      },
                    ),
                  ],
                );
        },
      ),
    );
  }
}
