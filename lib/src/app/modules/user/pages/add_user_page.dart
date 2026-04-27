import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:post_app/src/app/data/dtos/user/new_user_dto.dart';
import 'package:post_app/src/app/domain/validators/user/new_address_validator.dart';
import 'package:post_app/src/app/domain/validators/user/new_user_validator.dart';
import 'package:post_app/src/app/modules/initial/ui/view_models/user_view_model.dart';
import 'package:post_app/src/app/shared/routes/user_module_routes.dart';
import 'package:post_app/src/app/shared/widgets/app_button.dart';
import 'package:post_app/src/app/shared/widgets/app_container.dart';

class AddUserPage extends ConsumerStatefulWidget {
  const AddUserPage({super.key});

  @override
  ConsumerState<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends ConsumerState<AddUserPage> {
  final newUserValidator = NewUserValidator();
  final newAddressValidator = NewAddressValidator();
  final newUserDto = NewUserDto.empty();

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
                final newUser = await ref.read(userStateProvider.notifier).addUser(newUserDto);

                if (newUser == null || !mounted) {
                  return;
                }

                final currentUser = ref.read(userStateProvider).currentUser;
                if (currentUser == null) {
                  await ref.read(userStateProvider.notifier).savePrimaryUser(newUser);
                  if (mounted) {
                    Modular.to.navigate(UserModuleRoutes.HOME_PAGE);
                  }
                } else {
                  Modular.to.pop();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
