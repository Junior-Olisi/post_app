import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/data/strategies/user_list/user_list_context.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/modules/initial/ui/pages/initial_page.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

mixin InitialPageMixin<T extends ConsumerStatefulWidget> on ConsumerState<InitialPage> {
  Future<void> showUserOptionsDialog() async {
    final size = MediaQuery.sizeOf(context);

    final controller = ref.read(userStateProvider.notifier);
    final localUsers = await controller.getAllUsers(strategyType: StrategyType.Local);

    UserList usersList = localUsers ?? const UserList(users: []);

    if (usersList.users.isEmpty) {
      final remoteUsers = await controller.getAllUsers(strategyType: StrategyType.Remote);
      usersList = remoteUsers ?? const UserList(users: []);
    }

    final errorMessage = ref.read(userStateProvider).errorMessage;
    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(errorMessage),
        ),
      );
      controller.clearError();
      return;
    }

    if (usersList.users.isEmpty || !mounted) {
      return;
    }

    return showDialog(
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
            children: usersList.users
                .map(
                  (user) => UserTile(
                    user: user,
                    onTap: () async {
                      final selectedUser = await controller.savePrimaryUser(user);
                      if (!mounted || selectedUser == null) {
                        return;
                      }

                      log(user.name);
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

  Widget initialPageBody() {
    final size = MediaQuery.sizeOf(context);

    return AppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text('Seja bem vindo(a) ao Post App!'),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.048),
            child: Text(
              'Selecione um perfil de usuário para começar',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
          ),
          AppButton(
            onPressed: showUserOptionsDialog,
            text: 'Selecionar Perfil de Usuário',
          ),
          Spacer(),
        ],
      ),
    );
  }
}
