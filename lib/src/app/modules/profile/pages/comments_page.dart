import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/domain/entities/user/user.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';
import 'package:post_app/src/app/shared/widgets/user_tile.dart';

class CommentsPage extends ConsumerStatefulWidget {
  const CommentsPage({
    required this.user,
    super.key,
  });

  final User user;

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(postStateProvider.notifier).getUserComments(widget.user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final postState = ref.watch(postStateProvider);

    if (postState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            content: Text(postState.errorMessage!),
          ),
        );
        ref.read(postStateProvider.notifier).clearError();
      });
    }

    return AppContainer(
      child: ListView(
        children: [
          UserTile(
            user: widget.user,
            onTap: null,
            tileType: UserTileType.large,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.024,
            ),
            child: Text(
              'Comentários',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ),
          if (postState.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ...postState.userComments.map((comment) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  comment.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                  comment.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }),
        ],
      ),
    );
  }
}
