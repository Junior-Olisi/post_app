import 'package:flutter_modular/flutter_modular.dart';
import 'pages/splash_page.dart';

class InitialModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => const SplashPage(),
    );
  }
}
