import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/user/mixins/user_selection_page_mixin.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class UserSelectionPage extends StatefulWidget {
  const UserSelectionPage({
    required this.userViewModel,
    required this.postViewModel,
    super.key,
  });

  final UserViewModel userViewModel;
  final PostViewModel postViewModel;

  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> with UserSelectionPageMixin<UserSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.024;

    final notSelectedUsersList = widget.userViewModel.usersList.where((user) => user.id != widget.userViewModel.currentUser.id).toList();

    return AppContainer(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Modular.to.pushNamed(UserModuleRoutes.ADD_USER_PAGE);
        },
        child: Icon(Icons.add),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selecionar Usuário',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  'Selecione um novo perfil para visualizar as atividades e informações.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.7,
            child: ListView.builder(
              itemCount: notSelectedUsersList.length,
              itemBuilder: (_, i) {
                final user = notSelectedUsersList[i];

                return UserTile(
                  user: user,
                  onTap: () async {
                    await widget.userViewModel.selectSecondaryUserProfileCommand.execute(user);
                  },
                  tileType: UserTileType.small,
                );
              },
              shrinkWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
