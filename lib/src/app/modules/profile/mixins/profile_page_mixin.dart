import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/modules/profile/pages/profile_page.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

mixin ProfilePageMixin<T extends StatefulWidget> on State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    widget.userViewModel.exitFromProfileSearchCommand.addListener(exitFromProfileSearchListenable);
    widget.userViewModel.exitFromApplicationCommand.addListener(exitFromApplicationListenable);
  }

  showApplicationClosingDialog() {
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
          'Sair do perfil',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: size.height * 0.14,
          width: size.width,
          child: Column(
            children: [
              Text(
                'Ao sair do perfil atual, todas as ações realizadas  serão perdidas. Deseja mesmo sair?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Modular.to.pop();
              await widget.userViewModel.exitFromApplicationCommand.execute();
            },
            child: Text(
              'SIM',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Modular.to.pop();
            },
            child: Text(
              'NÃO',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
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
      Modular.to.navigate(InitialModuleRoutes.ROOT);
    }
  }

  exitFromApplicationListenable() {
    final result = widget.userViewModel.exitFromApplicationCommand.value;

    if (result is FailureCommand<Unit>) {
      final error = result.error as UserError;
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<Unit>) {
      Modular.to.navigate(InitialModuleRoutes.ROOT);
    }
  }

  @override
  void dispose() {
    widget.userViewModel.exitFromProfileSearchCommand.removeListener(exitFromProfileSearchListenable);
    widget.userViewModel.exitFromApplicationCommand.removeListener(exitFromApplicationListenable);
    super.dispose();
  }
}
