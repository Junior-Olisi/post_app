import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/profile/pages/comments_page.dart';
import 'package:post_app/src/app/modules/profile/pages/profile_page.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';

class ProfileModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      ProfileModuleRoutes.PROFILE_PAGE,
      child: (args) => ProfilePage(
        user: r.args.data,
        userViewModel: Modular.get<UserViewModel>(),
        postViewModel: Modular.get<PostViewModel>(),
      ),
    );

    r.child(
      ProfileModuleRoutes.COMMENTS_PAGE,
      child: (args) => CommentsPage(
        user: r.args.data,
        postViewModel: Modular.get<PostViewModel>(),
      ),
    );
  }
}
