import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/post/post_module.dart';
import 'package:post_app/src/app/modules/profile/profile_module.dart';
import 'package:post_app/src/app/modules/user/user_module.dart';

import 'ui/pages/splash_page.dart';

class InitialModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const SplashPage(),
    );

    r.module(
      '/user',
      module: UserModule(),
    );

    r.module(
      '/post',
      module: PostModule(),
    );

    r.module(
      '/profile',
      module: ProfileModule(),
    );
  }
}
