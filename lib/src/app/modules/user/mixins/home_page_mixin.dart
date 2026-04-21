import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/errors/post/post_error.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/entities/post/post_list.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/user/pages/home_page.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';
import 'package:result_command/result_command.dart';

mixin HomePageMixin<T extends StatefulWidget> on State<HomePage> {
  late bool isPrimaryUser = widget.userViewModel.currentUser.userType == UserType.primary;
  late bool isLoadingState =
      widget.postViewModel.getUserPostsCommand.value.isRunning || //
      widget.userViewModel.exitFromProfileSearchCommand.value.isRunning;

  @override
  void initState() {
    super.initState();
    final user = widget.userViewModel.currentUser;

    widget.postViewModel.getUserPostsCommand.addListener(getUserPostsListenable);
    widget.postViewModel.likePostCommand.addListener(likePostListenable);

    widget.postViewModel.getUserPostsCommand.execute(user);
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
      List<Post> userPosts = [];

      for (Post post in result.value.posts) {
        final user = widget.userViewModel.currentUser;
        post = post.copyWith(postOwner: user);
        userPosts.add(post);
      }

      widget.postViewModel.userPostsList.value = userPosts;
    }
  }

  likePostListenable() {
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

  Widget homePageBody() {
    final size = MediaQuery.sizeOf(context);

    return AppContainer(
      floatingActionButton: isPrimaryUser
          ? FloatingActionButton(
              onPressed: () {
                Modular.to.pushNamed('${PostModuleRoutes.POST_MANAGEMENT_PAGE}/?mode=create');
              },
              child: Icon(Icons.add),
            )
          : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          widget.userViewModel.exitFromProfileSearchCommand,
          widget.postViewModel.getUserPostsCommand,
        ]),
        builder: (_, __) {
          return isLoadingState
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
                            : Visibility(
                                visible: widget.postViewModel.userPostsList.value.isNotEmpty,
                                replacement: Expanded(
                                  child: Center(
                                    child: Text(
                                      'O usuário não possui nenhum post salvo',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                ),
                                child: Expanded(
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

  @override
  void dispose() {
    widget.postViewModel.getUserPostsCommand.removeListener(getUserPostsListenable);
    widget.postViewModel.likePostCommand.removeListener(likePostListenable);

    super.dispose();
  }
}
