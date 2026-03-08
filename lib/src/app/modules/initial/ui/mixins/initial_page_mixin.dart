import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/initial/ui/pages/initial_page.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

mixin InitialPageMixin<T extends StatefulWidget> on State<InitialPage> {
  final userViewModel = Modular.get<UserViewModel>();
  final postViewModel = Modular.get<PostViewModel>();

  showUserOptionsDialog() {
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
          'Selecionar Usuário',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: size.width,
          child: ListView(
            children: userViewModel.usersList
                .map(
                  (user) => UserTile(
                    user: user,
                    onTap: () {
                      userViewModel.primaryUser = user;
                      Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
                    },
                    tileType: UserTileType.small,
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          Container(),
        ],
      ),
    );
  }
}
