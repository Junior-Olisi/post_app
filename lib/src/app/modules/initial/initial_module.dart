import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/data/interfaces/ilocal_storage_service.dart';
import 'package:post_app/src/app/data/interfaces/iuser_repository.dart';
import 'package:post_app/src/app/data/repositories/user_repository.dart';
import 'package:post_app/src/app/data/services/user_local_storage_service.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/modules/initial/ui/pages/initial_page.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/post/post_module.dart';
import 'package:post_app/src/app/modules/profile/profile_module.dart';
import 'package:post_app/src/app/modules/user/user_module.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';

import 'ui/pages/splash_page.dart';

class InitialModule extends Module {
  @override
  void binds(Injector i) {
    i.add<Dio>(() => Dio(BaseOptions()));
    i.addSingleton<IlocalStorageService<User>>(UserLocalStorageService.new);
    i.addSingleton<IUserRepository>(UserRepository.new);
    i.addSingleton<UserViewModel>(UserViewModel.new);
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
