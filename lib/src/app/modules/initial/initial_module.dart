import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/interfaces/ipost_repository.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/repositories/post_repository.dart';
import 'package:post_app/src/app/data/repositories/user_repository.dart';
import 'package:post_app/src/app/modules/initial/ui/pages/initial_page.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/post/post_module.dart';
import 'package:post_app/src/app/modules/profile/profile_module.dart';
import 'package:post_app/src/app/modules/user/user_module.dart';
import 'package:post_app/src/app/shared/common_module.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';

import 'ui/pages/splash_page.dart';

class InitialModule extends Module {
  @override
  List<Module> get imports => [
    CommonModule(),
  ];

  @override
  void binds(Injector i) {
    i.addSingleton<IUserRepository>(UserRepository.new);
    i.addSingleton<UserViewModel>(UserViewModel.new);
    i.addSingleton<IPostRepository>(PostRepository.new);
    i.addSingleton<PostViewModel>(PostViewModel.new);
  }

  @override
  void routes(RouteManager r) {
    r.child(
      InitialModuleRoutes.ROOT,
      child: (context) => const SplashPage(),
    );
    r.child(
      InitialModuleRoutes.INITIAL,
      child: (context) => const InitialPage(),
    );

    r.module(
      UserModuleRoutes.ROOT,
      module: UserModule(),
    );

    r.module(
      ProfileModuleRoutes.ROOT,
      module: ProfileModule(),
    );

    r.module(
      PostModuleRoutes.ROOT,
      module: PostModule(),
    );
  }
}
