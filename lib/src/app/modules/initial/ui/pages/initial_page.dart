import 'package:flutter/material.dart';
import 'package:post_app/src/app/modules/initial/ui/mixins/initial_page_mixin.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> with InitialPageMixin {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AppContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text('Seja bem vindo(a) ao Post App!'),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.048),
            child: Text(
              'Selecione um perfil de usuário para começar',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
          ),
          AppButton(
            onPressed: showUserOptionsDialog,
            text: 'Selecionar Perfil de Usuário',
          ),
          Spacer(),
        ],
      ),
    );
  }
}
