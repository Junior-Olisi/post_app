import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/errors/user/user_error.dart';
import 'package:post_app/src/app/data/strategies/user_list/user_list_context.dart';
import 'package:post_app/src/app/domain/entities/user/user_list.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:result_command/result_command.dart';

mixin SplashPageMixin<T extends StatefulWidget> on State<T> {
  final userViewModel = Modular.get<UserViewModel>();

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late String logoImage;

  int initializationTimeSpanInSeconds = 2;

  ValueNotifier<bool> showRetryButton = ValueNotifier(false);

  setSplashPageLogoDisplay() {
    logoImage = Theme.of(context).brightness == Brightness.light
        ? 'assets/logo/light_logo.png' //
        : 'assets/logo/dark_logo.png';
  }

  void setupAnimation(TickerProvider tickerProvider) {
    animationController = AnimationController(
      duration: Duration(seconds: initializationTimeSpanInSeconds),
      vsync: tickerProvider,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    animationController.forward();
  }

  Future<void> initializeApp() async {
    await Future.delayed(Duration(seconds: initializationTimeSpanInSeconds));
    userViewModel.getAllUsersCommand.addListener(getLocalUsersListenable);
    await userViewModel.getAllUsersCommand.execute(StrategyType.Local);
  }

  getLocalUsersListenable() async {
    final result = userViewModel.getAllUsersCommand.value;

    if (result is FailureCommand<UserList>) {
      final error = result.error as UserError;

      showRetryButton.value = true;

      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          content: Text(error.message),
        ),
      );
    }

    if (result is SuccessCommand<UserList>) {
      if (result.value.users.isNotEmpty) {
        userViewModel.usersList = result.value.users;

        bool primaryUserAlreadySaved = userViewModel.usersList.any((user) => user.userType == UserType.primary);

        if (primaryUserAlreadySaved) {
          final primaryUser = userViewModel.usersList.where((user) => user.userType == UserType.primary).first;
          userViewModel.currentUser = primaryUser;
          return Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
        }

        Modular.to.pushReplacementNamed(InitialModuleRoutes.INITIAL);
      } else {
        await userViewModel.getAllUsersCommand.execute(StrategyType.Remote);
      }
    }
  }

  Widget splashPageBody() {
    final size = MediaQuery.sizeOf(context);

    setSplashPageLogoDisplay();

    return AppContainer(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Center(
          child: Column(
            spacing: size.height * 0.024,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: size.height * 0.115,
                height: size.height * 0.115,
                child: Image.asset(
                  logoImage,
                  fit: BoxFit.contain,
                ),
              ),
              AnimatedBuilder(
                animation: Listenable.merge(
                  [
                    userViewModel.getAllUsersCommand,
                    showRetryButton,
                  ],
                ),
                builder: (_, __) {
                  final isLoadingState = userViewModel.getAllUsersCommand.value.isRunning;

                  return isLoadingState
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Visibility(
                          visible: showRetryButton.value,
                          replacement: Container(),
                          child: AppButton(
                            onPressed: () async {
                              await userViewModel.getAllUsersCommand.execute(StrategyType.Local);
                            },
                            text: 'Tentar Novamente',
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    userViewModel.getAllUsersCommand.removeListener(getLocalUsersListenable);
    super.dispose();
  }
}
