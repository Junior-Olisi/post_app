import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/ui/modules/initial/initial_module.dart';
import 'package:post_app/src/app/ui/modules/post/post_module.dart';
import 'package:post_app/src/app/ui/modules/profile/profile_module.dart';
import 'package:post_app/src/app/ui/modules/user/user_module.dart';

class AppModule extends Module {
  @override
  void routes(RouteManager r) {
    r.module(
      '/',
      module: InitialModule(),
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
