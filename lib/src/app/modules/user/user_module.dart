import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';

import 'pages/home_page.dart';

class UserModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '${UserModuleRoutes.HOME_PAGE}/:user_id',
      child: (context) => const HomePage(),
      transition: TransitionType.fadeIn,
    );
  }
}
