import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';

mixin InitialPageMixin<T extends StatefulWidget> on State<T> {
  final userViewModel = Modular.get<UserViewModel>();

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
                  (user) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.profileImage ?? '',
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      '@${user.username}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    onTap: () {
                      userViewModel.primaryUser = user;

                      Modular.to.navigate('${UserModuleRoutes.HOME_PAGE}/${user.id}');
                    },
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
