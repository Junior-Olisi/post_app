import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:result_command/result_command.dart';

mixin SplashPageMixin<T extends StatefulWidget> on State<T> {
  final userViewModel = Modular.get<UserViewModel>();

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  ValueNotifier<bool> showRetryButton = ValueNotifier(false);

  void setupAnimation(TickerProvider tickerProvider) {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: tickerProvider,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();
  }

  Future<void> initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    userViewModel.getAllUsersCommand.addListener(getAllUsersListenable);
    await userViewModel.getAllUsersCommand.execute();
  }

  getAllUsersListenable() async {
    final result = userViewModel.getAllUsersCommand.value;

    if (result is FailureCommand<UserList>) {
      showRetryButton.value = true;

      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text('Erro ao obter lista de usuários. Tente novamente'),
        ),
      );
    }

    if (result is SuccessCommand<UserList>) {
      userViewModel.usersList = result.value.users;

      bool primaryUserAlreadySaved = userViewModel.usersList.any((user) => user.userType == UserType.primary);

      if (primaryUserAlreadySaved) {
        final primaryUser = userViewModel.usersList.where((user) => user.userType == UserType.primary).first;
        userViewModel.currentUser = primaryUser;
        return Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
      }

      Modular.to.pushReplacementNamed(InitialModuleRoutes.INITIAL);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    userViewModel.getAllUsersCommand.removeListener(getAllUsersListenable);
    super.dispose();
  }
}
