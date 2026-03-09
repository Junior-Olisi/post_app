import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/user/pages/user_selection_page.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';

import 'pages/home_page.dart';

class UserModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      UserModuleRoutes.HOME_PAGE,
      child: (context) => HomePage(
        userViewModel: Modular.get<UserViewModel>(),
        postViewModel: Modular.get<PostViewModel>(),
      ),
      transition: TransitionType.fadeIn,
    );

    r.child(
      UserModuleRoutes.USER_SELECTION_PAGE,
      child: (context) => UserSelectionPage(
        userViewModel: Modular.get<UserViewModel>(),
        postViewModel: Modular.get<PostViewModel>(),
      ),
    );
  }
}
