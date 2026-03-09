import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/post/pages/post_management_page.dart';
import 'package:post_app/src/app/modules/post/pages/post_page.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';

class PostModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '${PostModuleRoutes.POST_MANAGEMENT_PAGE}/:mode',
      child: (context) => PostManagementPage(
        userViewModel: Modular.get<UserViewModel>(),
        postViewModel: Modular.get<PostViewModel>(),
        post: r.args.data,
      ),
    );

    r.child(
      PostModuleRoutes.POST_PAGE,
      child: (context) => PostPage(
        userViewModel: Modular.get<UserViewModel>(),
        postViewModel: Modular.get<PostViewModel>(),
        post: r.args.data,
      ),
    );
  }
}
