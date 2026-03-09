import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:post_app/src/app/domain/entities/post/post.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/post_view_model.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/post/mixins/post_management_page_mixin.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class PostManagementPage extends StatefulWidget {
  const PostManagementPage({
    required this.userViewModel,
    required this.postViewModel,
    this.post,
    super.key,
  });

  final UserViewModel userViewModel;
  final PostViewModel postViewModel;
  final Post? post;

  @override
  State<PostManagementPage> createState() => _PostManagementPageState();
}

class _PostManagementPageState extends State<PostManagementPage> with PostManagementPageMixin<PostManagementPage> {
  final pageMode = Modular.args.queryParams['mode'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.048;

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
              visible: !widget.postViewModel.createPostCommand.value.isRunning,
              replacement: Center(
                child: CircularProgressIndicator(),
              ),
              child: AppButton(
                onPressed: () {
                  if (newPostValidator.validate(newPostDto).isValid) {
                    newPostDto.userId = widget.userViewModel.primaryUser.id;
                    widget.postViewModel.createPostCommand.execute(newPostDto);
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
              visible: !widget.postViewModel.updatePostCommand.value.isRunning,
              replacement: Center(
                child: CircularProgressIndicator(),
              ),
              child: AppButton(
                onPressed: () {
                  if (widget.post == null) {
                    return;
                  }

                  if (updatePostValidator.validate(updatePostDto).isValid) {
                    widget.postViewModel.updatePostCommand.execute(updatePostDto, widget.post!);
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
