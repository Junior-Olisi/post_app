import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/data/dtos/post/new_post_dto.dart';
import 'package:post_app/src/app/data/dtos/post/update_post_dto.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/domain/validators/post/new_post_validator.dart';
import 'package:post_app/src/app/domain/validators/post/update_post_validator.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/post_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class PostManagementPage extends ConsumerStatefulWidget {
  const PostManagementPage({this.post, super.key});

  final Post? post;

  @override
  ConsumerState<PostManagementPage> createState() => _PostManagementPageState();
}

class _PostManagementPageState extends ConsumerState<PostManagementPage> {
  final newPostValidator = NewPostValidator();
  final updatePostValidator = UpdatePostValidator();
  final newPostDto = NewPostDto.empty();
  final updatePostDto = UpdatePostDto.empty();

  final pageMode = Modular.args.queryParams['mode'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.048;
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

    return switch (pageMode) {
      'create' => AppContainer(
        child: Column(
          spacing: spacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo Post',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  'Crie um novo post',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Column(
              spacing: size.height * 0.016,
              children: [
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: newPostValidator.byField(newPostDto, 'title'),
                  decoration: InputDecoration(
                    label: Text('Título'),
                  ),
                  onChanged: newPostDto.setTitle,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: newPostValidator.byField(newPostDto, 'body'),
                  decoration: InputDecoration(
                    label: Text('Conteúdo'),
                  ),
                  onChanged: newPostDto.setBody,
                ),
              ],
            ),
            Spacer(),
            Visibility(
              visible: !postState.isLoading,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
              child: AppButton(
                onPressed: () async {
                  if (newPostValidator.validate(newPostDto).isValid) {
                    final currentUser = ref.read(userStateProvider).currentUser;
                    if (currentUser == null) {
                      return;
                    }

                    newPostDto.userId = currentUser.id;
                    final createdPost = await ref.read(postStateProvider.notifier).createPost(newPostDto);

                    if (createdPost != null && mounted) {
                      Modular.to.pushReplacementNamed(PostModuleRoutes.POST_PAGE, arguments: createdPost);
                    }
                  }
                },
                text: 'Adicionar',
              ),
            ),
          ],
        ),
      ),
      'update' => AppContainer(
        child: Column(
          spacing: spacing,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post?.title ?? '',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  'Atualize as informações do post',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Column(
              spacing: size.height * 0.016,
              children: [
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: updatePostValidator.byField(updatePostDto, 'title'),
                  decoration: InputDecoration(
                    label: Text('Título'),
                  ),
                  onChanged: updatePostDto.setTitle,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: updatePostValidator.byField(updatePostDto, 'body'),
                  decoration: InputDecoration(
                    label: Text('Conteúdo'),
                  ),
                  onChanged: updatePostDto.setBody,
                ),
              ],
            ),
            Spacer(),
            Visibility(
              visible: !postState.isLoading,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
              child: AppButton(
                onPressed: () async {
                  if (widget.post == null) {
                    return;
                  }

                  if (updatePostValidator.validate(updatePostDto).isValid) {
                    final updatedPost = await ref.read(postStateProvider.notifier).updatePost(updatePostDto, widget.post!);

                    if (updatedPost != null && mounted) {
                      Modular.to.pushReplacementNamed(PostModuleRoutes.POST_PAGE, arguments: updatedPost);
                    }
                  }
                },
                text: 'Salvar',
              ),
            ),
          ],
        ),
      ),
      _ => SizedBox(
        child: Text('ERROR MODE'),
      ),
    };
  }
}
