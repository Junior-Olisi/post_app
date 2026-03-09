import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/profile/mixins/profile_page_mixin.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.user,
    required this.userViewModel,
    required this.postViewModel,
    super.key,
  });

  final User user;
  final UserViewModel userViewModel;
  final PostViewModel postViewModel;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with ProfilePageMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.048;

    return DefaultTabController(
      length: 2,
      child: AppContainer(
        child: Column(
          spacing: spacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserTile(
              user: widget.user,
              onTap: null,
              tileType: UserTileType.large,
              trailing: IconButton(
                onPressed: () async {
                  await widget.userViewModel.exitFromProfileSearchCommand.execute();
                },
                icon: Icon(
                  Icons.logout,
                ),
              ),
            ),
            TabBar(
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorAnimation: TabIndicatorAnimation.elastic,
              dividerColor: Colors.transparent,
              indicatorColor: Theme.of(context).colorScheme.onSurface,
              labelColor: Theme.of(context).colorScheme.onSurface,
              tabs: [
                Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                    ),
                    Text('Atividades'),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.menu,
                    ),
                    Text('Informações'),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      if (widget.user.userType == UserType.primary)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('Favoritos'),
                          trailing: Icon(
                            Icons.chevron_right_outlined,
                          ),
                          onTap: () {},
                        ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Comentários'),
                        trailing: Icon(
                          Icons.chevron_right_outlined,
                        ),
                        onTap: () {
                          Modular.to.pushNamed(
                            ProfileModuleRoutes.COMMENTS_PAGE,
                            arguments: widget.user,
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    spacing: spacing,
                    children: [
                      Row(
                        spacing: spacing / 2,
                        children: [
                          Icon(Icons.location_on),
                          Text(
                            '${widget.user.address?.street ?? ''},${widget.user.address?.suite ?? ''}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      Row(
                        spacing: spacing / 2,
                        children: [
                          Icon(Icons.phone),
                          Text(
                            widget.user.phone,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      Row(
                        spacing: spacing / 2,
                        children: [
                          Icon(FluentIcons.globe_12_filled),
                          Text(
                            widget.user.website,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
