import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/data/strategies/user_list/user_list_context.dart';
import 'package:post_app/src/app/modules/initial/ui/pages/splash_page.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

mixin SplashPageMixin<T extends ConsumerStatefulWidget> on ConsumerState<SplashPage> {
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

    final controller = ref.read(userStateProvider.notifier);
    final localUsers = await controller.getAllUsers(strategyType: StrategyType.Local);

    if (!mounted) {
      return;
    }

    if (localUsers == null) {
      showRetryButton.value = true;
      return;
    }

    if (localUsers.users.isNotEmpty) {
      if (ref.read(userStateProvider).currentUser != null) {
        Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
      } else {
        Modular.to.pushReplacementNamed(InitialModuleRoutes.INITIAL);
      }
      return;
    }

    final remoteUsers = await controller.getAllUsers(strategyType: StrategyType.Remote);

    if (!mounted) {
      return;
    }

    if (remoteUsers == null) {
      showRetryButton.value = true;
      return;
    }

    Modular.to.pushReplacementNamed(InitialModuleRoutes.INITIAL);
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
                    showRetryButton,
                  ],
                ),
                builder: (_, __) {
                  return Visibility(
                    visible: showRetryButton.value,
                    replacement: Container(),
                    child: AppButton(
                      onPressed: () async {
                        showRetryButton.value = false;
                        await initializeApp();
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
    super.dispose();
  }
}
