import 'package:flutter/material.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/modules/user/mixins/add_user_page_mixin.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({required this.userViewModel, super.key});

  final UserViewModel userViewModel;

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> with AddUserPageMixin<AddUserPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final spacing = size.height * 0.048;

    return AppContainer(
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing / 4,
            children: [
              Text(
                'Adicionar Usuário',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                'Adicione um novo usuário preenchendo o formulário abaixo',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          SizedBox(height: spacing / 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing / 4,
            children: [
              Text(
                'Informações Pessoais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                validator: newUserValidator.byField(newUserDto, 'name'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: newUserDto.setName,
                decoration: InputDecoration(
                  label: Text('Nome'),
                ),
              ),
              TextFormField(
                validator: newUserValidator.byField(newUserDto, 'username'),
                onChanged: newUserDto.setUsername,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  label: Text('Apelido'),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing / 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing / 4,
            children: [
              Text(
                'Endereço',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                spacing: spacing / 4,
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      validator: newUserValidator.byField(newUserDto, 'address.street'),
                      onChanged: newUserDto.setStreet,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        label: Text('Endereço'),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      validator: newUserValidator.byField(newUserDto, 'address.suite'),
                      onChanged: newUserDto.setSuite,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        label: Text('N°'),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextFormField(
                validator: newUserValidator.byField(newUserDto, 'address.city'),
                onChanged: newUserDto.setCity,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  label: Text('Cidade'),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing / 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing / 4,
            children: [
              Text(
                'Contato',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                validator: newUserValidator.byField(newUserDto, 'phone'),
                onChanged: newUserDto.setPhone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  label: Text('Telefone'),
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                validator: newUserValidator.byField(newUserDto, 'email'),
                onChanged: newUserDto.setEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  label: Text('E-mail'),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: newUserDto.setWebsite,
                decoration: InputDecoration(
                  label: Text('Website(Opcional)'),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          AppButton(
            text: 'Salvar',
            onPressed: () async {
              if (newUserValidator.validate(newUserDto).isValid) {
                await widget.userViewModel.addUserCommand.execute(newUserDto);
              }
            },
          ),
        ],
      ),
    );
  }
}
