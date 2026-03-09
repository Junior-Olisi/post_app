import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/validators/user/new_address_validator.dart';
import 'package:post_app/src/app/domain/validators/user/new_user_validator.dart';
import 'package:post_app/src/app/modules/user/pages/add_user_page.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:result_command/result_command.dart';

mixin AddUserPageMixin<T extends StatefulWidget> on State<AddUserPage> {
  final newUserValidator = NewUserValidator();
  final newAddressValidator = NewAddressValidator();
  final newUserDto = NewUserDto.empty();

  @override
  void initState() {
    super.initState();
    widget.userViewModel.addUserCommand.addListener(addUserListenable);
  }

  addUserListenable() {
    final result = widget.userViewModel.addUserCommand.value;

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
      final user = result.value;

      List<User> usersList = [];
      usersList.addAll(widget.userViewModel.usersList);
      usersList.add(user);

      widget.userViewModel.usersList = usersList;

      Modular.to.pushNamed(UserModuleRoutes.HOME_PAGE);
    }
  }

  @override
  void dispose() {
    widget.userViewModel.addUserCommand.removeListener(addUserListenable);
    super.dispose();
  }
}
