import 'package:flutter/cupertino.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.048;

    return AppContainer(
      child: Column(
        spacing: spacing,
        children: [
          Row(
            children: [],
          ),
        ],
      ),
    );
  }
}
