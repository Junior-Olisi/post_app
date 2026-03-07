import 'package:flutter_modular/flutter_modular.dart';
import 'pages/home_page.dart';

class UserModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/home',
      child: (context) => const HomePage(),
      transition: TransitionType.fadeIn,
    );
  }
}
