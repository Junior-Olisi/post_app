import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/modules/profile/pages/profile_page.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:result_command/result_command.dart';

mixin ProfilePageMixin<T extends StatefulWidget> on State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    widget.userViewModel.exitFromProfileSearchCommand.addListener(exitFromProfileSearchListenable);
  }

  exitFromProfileSearchListenable() {
    final result = widget.userViewModel.exitFromProfileSearchCommand.value;

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
      widget.userViewModel.currentUser = result.value;

      Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
    }
  }

  @override
  void dispose() {
    widget.userViewModel.exitFromProfileSearchCommand.removeListener(exitFromProfileSearchListenable);
    super.dispose();
  }
}
