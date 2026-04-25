import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/domain/enums/user_type.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/initial_module_routes.dart';
import 'package:post_app/src/app/shared/routes/profile_module_routes.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    required this.user,
    super.key,
  });

  final User user;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _showApplicationClosingDialog() async {
    final size = MediaQuery.sizeOf(context);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        buttonPadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.048),
        titlePadding: EdgeInsets.symmetric(vertical: size.height * 0.02),
        actionsPadding: EdgeInsets.zero,
        actionsAlignment: MainAxisAlignment.center,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Sair do perfil',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          height: size.height * 0.14,
          width: size.width,
          child: Column(
            children: [
              Text(
                'Ao sair do perfil atual, todas as ações realizadas  serão perdidas. Deseja mesmo sair?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Modular.to.pop();
              final success = await ref.read(userStateProvider.notifier).exitFromApplication();
              if (success && mounted) {
                Modular.to.navigate(InitialModuleRoutes.ROOT);
              }
            },
            child: Text(
              'SIM',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Modular.to.pop();
            },
            child: Text(
              'NÃO',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.048;
    final userState = ref.watch(userStateProvider);

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

    return DefaultTabController(
      length: 2,
      child: AppContainer(
        child: Column(
          spacing: spacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserTile(
              user: widget.user,
              onTap: null,
              tileType: UserTileType.large,
              trailing: IconButton(
                onPressed: () async {
                  if (widget.user.userType == UserType.primary) {
                    await _showApplicationClosingDialog();
                  } else {
                    final primaryUser = await ref.read(userStateProvider.notifier).exitFromProfileSearch();
                    if (primaryUser != null && mounted) {
                      Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
                    }
                  }
                },
                icon: Icon(
                  Icons.logout,
                ),
              ),
            ),
            TabBar(
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorAnimation: TabIndicatorAnimation.elastic,
              dividerColor: Colors.transparent,
              indicatorColor: Theme.of(context).colorScheme.onSurface,
              labelColor: Theme.of(context).colorScheme.onSurface,
              tabs: [
                Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                    ),
                    Text('Atividades'),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.menu,
                    ),
                    Text('Informações'),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Comentários'),
                        trailing: Icon(
                          Icons.chevron_right_outlined,
                        ),
                        onTap: () {
                          Modular.to.pushNamed(
                            ProfileModuleRoutes.COMMENTS_PAGE,
                            arguments: widget.user,
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    spacing: spacing,
                    children: [
                      Row(
                        spacing: spacing / 2,
                        children: [
                          Icon(Icons.location_on),
                          Text(
                            '${widget.user.address?.street ?? ''},${widget.user.address?.suite ?? ''}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      Row(
                        spacing: spacing / 2,
                        children: [
                          Icon(Icons.phone),
                          Text(
                            widget.user.phone,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      Row(
                        spacing: spacing / 2,
                        children: [
                          Icon(FluentIcons.globe_12_filled),
                          Text(
                            widget.user.website,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
