import 'package:flutter/material.dart';
import 'package:post_app/src/app/modules/initial/ui/mixins/splash_page_mixin.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin, SplashPageMixin<SplashPage> {
  @override
  void initState() {
    super.initState();
    setupAnimation(this);
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    final logoImage = Theme.of(context).brightness == Brightness.light
        ? 'assets/logo/light_logo.png' //
        : 'assets/logo/dark_logo.png';

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
                              await userViewModel.getAllUsersCommand.execute();
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
}
