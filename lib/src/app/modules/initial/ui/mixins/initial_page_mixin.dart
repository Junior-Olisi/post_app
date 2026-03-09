import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/modules/initial/ui/pages/initial_page.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';
import 'package:result_command/result_command.dart';

mixin InitialPageMixin<T extends StatefulWidget> on State<InitialPage> {
  final userViewModel = Modular.get<UserViewModel>();

  @override
  initState() {
    super.initState();

    userViewModel.savePrimaryUserCommand.addListener(savePrimaryUserListenable);
  }

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
                    onTap: () async {
                      await userViewModel.savePrimaryUserCommand.execute(user);
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

  savePrimaryUserListenable() async {
    final result = userViewModel.savePrimaryUserCommand.value;
    if (result is FailureCommand<User>) {
      final error = result.error as UserError;

      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<User>) {
      userViewModel.currentUser = result.value;

      return Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
    }
  }

  @override
  void dispose() {
    userViewModel.savePrimaryUserCommand.removeListener(savePrimaryUserListenable);

    super.dispose();
  }
}
