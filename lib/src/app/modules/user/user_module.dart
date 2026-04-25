import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/user/pages/add_user_page.dart';
import 'package:post_app/src/app/modules/user/pages/home_page.dart';
import 'package:post_app/src/app/modules/user/pages/user_selection_page.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';

class UserModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      UserModuleRoutes.HOME_PAGE,
      child: (context) => HomePage(),
      transition: TransitionType.fadeIn,
    );
    r.child(
      UserModuleRoutes.USER_SELECTION_PAGE,
      child: (context) => const UserSelectionPage(),
    );
    r.child(
      UserModuleRoutes.ADD_USER_PAGE,
      child: (context) => const AddUserPage(),
    );
  }
}
