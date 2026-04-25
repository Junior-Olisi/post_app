import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class UserSelectionPage extends ConsumerStatefulWidget {
  const UserSelectionPage({super.key});

  @override
  ConsumerState<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends ConsumerState<UserSelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(userStateProvider.notifier).getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.024;
    final userState = ref.watch(userStateProvider);

    final currentUser = userState.currentUser;
    final notSelectedUsersList = userState.list.users.where((user) => user.id != currentUser?.id).toList();

    if (userState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            content: Text(userState.errorMessage!),
          ),
        );
        ref.read(userStateProvider.notifier).clearError();
      });
    }

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
                    final selectedUser = await ref.read(userStateProvider.notifier).selectSecondaryUserProfile(user);
                    if (selectedUser == null || !mounted) {
                      return;
                    }

                    await ref.read(postStateProvider.notifier).getUserPosts(selectedUser);
                    if (mounted) {
                      Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
                    }
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
